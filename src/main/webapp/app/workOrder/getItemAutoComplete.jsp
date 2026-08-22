원료명(item_name)뿐만 아니라 work_order_1, work_order_2, chem_name 항목 중 어느 것에든 검색어가 포함되면 자동완성 결과로 조회되도록 SQL의 WHERE 조건을 OR 연산자로 확장하면 됩니다.

수정된 getItemAutoComplete.jsp 코드는 다음과 같습니다.

getItemAutoComplete.jsp
Java
<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    out.clear();
    request.setCharacterEncoding("UTF-8");

    String term = request.getParameter("term");
    if (term == null) {
        term = "";
    }

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
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

        // item_name, work_order_1, work_order_2, chem_name 중 하나라도 일치하면 조회
        String sql = "SELECT item_name, price FROM items " +
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
            double price = rs.getDouble("price");

            jsonBuilder.append("{");
            jsonBuilder.append("\"label\": \"").append(itemName).append("\",");
            jsonBuilder.append("\"value\": \"").append(itemName).append("\",");
            jsonBuilder.append("\"price\": ").append(price);
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