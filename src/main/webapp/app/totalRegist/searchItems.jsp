<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String category = request.getParameter("category");
    String keyword = request.getParameter("keyword");

    // DTO 형태의 Map 데이터를 담을 리스트
    List<Map<String, String>> list = new ArrayList<Map<String, String>>();

    if (keyword == null || keyword.trim().isEmpty()) {
        out.print("[]");
        return;
    }

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        String searchPattern = "%" + keyword.trim() + "%";
        String sql = "";

        if ("RAW".equals(category)) {
            // 원료(items)
            sql = "SELECT DISTINCT item_name FROM items "
                + "WHERE (item_name LIKE ? "
                + "   OR COALESCE(work_order_1, '') LIKE ? "
                + "   OR COALESCE(work_order_2, '') LIKE ? "
                + "   OR COALESCE(work_order_3, '') LIKE ?) "
                + "ORDER BY item_name ASC LIMIT 20";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, searchPattern);
            pstmt.setString(2, searchPattern);
            pstmt.setString(3, searchPattern);
            pstmt.setString(4, searchPattern);

        } else if ("PRODUCT".equals(category)) {
            // 완제품(products) - product_type 추가 조회
            sql = "SELECT DISTINCT item_name, product_type FROM products WHERE item_name LIKE ? ORDER BY item_name ASC LIMIT 20";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, searchPattern);

        } else if ("SUBSIDIARY".equals(category)) {
            // 부자재(subsidiary) - subsidiary_type, material_type 추가 조회
            sql = "SELECT DISTINCT item_name, subsidiary_type, material_type FROM subsidiary WHERE item_name LIKE ? ORDER BY item_name ASC LIMIT 20";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, searchPattern);
        }

        if (pstmt != null) {
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, String> item = new HashMap<String, String>();
                String itemName = rs.getString("item_name");
                item.put("itemName", itemName != null ? itemName : "");

                if ("PRODUCT".equals(category)) {
                    String pType = rs.getString("product_type");
                    item.put("productType", pType != null ? pType : "");
                } else if ("SUBSIDIARY".equals(category)) {
                    String sType = rs.getString("subsidiary_type");
                    String mType = rs.getString("material_type");
                    item.put("subsidiaryType", sType != null ? sType : "");
                    item.put("materialType", mType != null ? mType : "");
                }

                list.add(item);
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }

    // JSON 객체 배열 형태 직접 생성
    // [{ "label": "...", "value": "...", "type": "...", "material": "..." }, ...]
    StringBuilder json = new StringBuilder("[");
    for (int i = 0; i < list.size(); i++) {
        Map<String, String> map = list.get(i);
        String name = map.get("itemName").replace("\\", "\\\\").replace("\"", "\\\"");

        json.append("{");
        json.append("\"label\":\"").append(name).append("\",");
        json.append("\"value\":\"").append(name).append("\"");

        if ("PRODUCT".equals(category)) {
            String pType = map.get("productType").replace("\\", "\\\\").replace("\"", "\\\"");
            json.append(",\"type\":\"").append(pType).append("\"");
        } else if ("SUBSIDIARY".equals(category)) {
            String sType = map.get("subsidiaryType").replace("\\", "\\\\").replace("\"", "\\\"");
            String mType = map.get("materialType").replace("\\", "\\\\").replace("\"", "\\\"");
            json.append(",\"type\":\"").append(sType).append("\"");
            json.append(",\"material\":\"").append(mType).append("\"");
        }

        json.append("}");
        if (i < list.size() - 1) json.append(",");
    }
    json.append("]");

    out.print(json.toString());
%>