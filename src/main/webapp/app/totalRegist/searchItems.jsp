<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String category = request.getParameter("category");
    String keyword = request.getParameter("keyword");

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
            sql = "SELECT DISTINCT item_name FROM items "
                + "WHERE (item_name LIKE ? "
                + "   OR COALESCE(work_order_1, '') LIKE ? "
                + "   OR COALESCE(work_order_2, '') LIKE ?) "
                + "ORDER BY item_name ASC LIMIT 20";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, searchPattern);
            pstmt.setString(2, searchPattern);
            pstmt.setString(3, searchPattern);

        } else if ("PRODUCT".equals(category)) {
            sql = "SELECT DISTINCT item_name, product_type FROM products WHERE item_name LIKE ? ORDER BY item_name ASC LIMIT 20";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, searchPattern);

        } else if ("SUBSIDIARY".equals(category)) {
            // 부자재 조회 시 종류와 자재명 모두 조회
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

    StringBuilder json = new StringBuilder("[");
    for (int i = 0; i < list.size(); i++) {
        Map<String, String> map = list.get(i);
        String name = map.get("itemName").replace("\\", "\\\\").replace("\"", "\\\"");

        // 부자재일 경우 label에 [종류]제품명 형태로 설정, value는 실제 제품명만 들어가도록 처리
        String label = name;
        if ("SUBSIDIARY".equals(category)) {
            String sType = map.get("subsidiaryType");
            if (sType != null && !sType.trim().isEmpty()) {
                label = "[" + sType.trim() + "]" + name;
            }
        }

        json.append("{");
        json.append("\"label\":\"").append(label.replace("\\", "\\\\").replace("\"", "\\\"")).append("\",");
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