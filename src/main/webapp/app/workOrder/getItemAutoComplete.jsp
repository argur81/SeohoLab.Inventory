<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    out.clear();
    request.setCharacterEncoding("UTF-8");

    String term = request.getParameter("term");
    if (term == null) {
        term = "";
    }

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    StringBuilder jsonBuilder = new StringBuilder();
    jsonBuilder.append("[");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        // price_type 및 세부 단가 관련 컬럼 추가 조회
        String sql = "SELECT item_name, price_type, price, kg_qty_1, kg_price_1 FROM items " +
                    "WHERE item_name LIKE ? OR work_order_1 LIKE ? OR work_order_2 LIKE ? OR chem_name LIKE ? " +
                    "ORDER BY item_name ASC LIMIT 20";
        pstmt = conn.prepareStatement(sql);
        String searchKeyword = "%" + term + "%";
        pstmt.setString(1, searchKeyword);
        pstmt.setString(2, searchKeyword);
        pstmt.setString(3, searchKeyword);
        pstmt.setString(4, searchKeyword);
        
        rs = pstmt.executeQuery();

        boolean first = true;
        while (rs.next()) {
            if (!first) {
                jsonBuilder.append(",");
            }
            String itemName = rs.getString("item_name");
            String priceType = rs.getString("price_type");
            double price = rs.getDouble("price");
            double kgQty1 = rs.getDouble("kg_qty_1");
            double kgPrice1 = rs.getDouble("kg_price_1");

            jsonBuilder.append("{");
            jsonBuilder.append("\"label\": \"").append(itemName).append("\",");
            jsonBuilder.append("\"value\": \"").append(itemName).append("\",");
            jsonBuilder.append("\"priceType\": \"").append(priceType != null ? priceType : "1kg기준").append("\",");
            jsonBuilder.append("\"price\": ").append(price).append(",");
            jsonBuilder.append("\"kgQty1\": ").append(kgQty1).append(",");
            jsonBuilder.append("\"kgPrice1\": ").append(kgPrice1);
            jsonBuilder.append("}");

            first = false;
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }

    jsonBuilder.append("]");
    out.print(jsonBuilder.toString());
%>