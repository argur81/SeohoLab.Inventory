<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.simple.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String category = request.getParameter("category"); // RAW, PRODUCT, SUBSIDIARY
    String keyword = request.getParameter("keyword");

    JSONArray list = new JSONArray();

    if (category == null || keyword == null || keyword.trim().isEmpty()) {
        out.print(list.toJSONString());
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

        String sql = "";
        
        // 각 테이블 컬럼 구조 반영
        if ("RAW".equals(category)) {
            sql = "SELECT item_id AS id, item_name, lot_number, total_stock_kg AS stock FROM items WHERE item_name LIKE ? LIMIT 10";
        } else if ("PRODUCT".equals(category)) {
            sql = "SELECT product_id AS id, item_name, product_type, lot_number, stock_qty AS stock FROM products WHERE item_name LIKE ? LIMIT 10";
        } else if ("SUBSIDIARY".equals(category)) {
            sql = "SELECT subsidiary_id AS id, item_name, subsidiary_type, stock_qty AS stock FROM subsidiary WHERE item_name LIKE ? LIMIT 10";
        }

        if (!sql.isEmpty()) {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "%" + keyword.trim() + "%");
            rs = pstmt.executeQuery();

            while (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("id", rs.getInt("id"));
                obj.put("name", rs.getString("item_name"));
                
                // 원료/완제품은 Lot 번호 추가, 완제품/부자재는 Type 추가 정보 전달
                if ("RAW".equals(category)) {
                    obj.put("sub_info", "Lot: " + rs.getString("lot_number"));
                } else if ("PRODUCT".equals(category)) {
                    obj.put("sub_info", "[" + rs.getString("product_type") + "] Lot: " + rs.getString("lot_number"));
                } else if ("SUBSIDIARY".equals(category)) {
                    obj.put("sub_info", "[" + rs.getString("subsidiary_type") + "]");
                }

                obj.put("stock", rs.getObject("stock"));
                list.add(obj);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }

    out.print(list.toJSONString());
%>