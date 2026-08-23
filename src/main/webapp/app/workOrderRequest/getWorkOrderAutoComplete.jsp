<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, org.json.simple.*" %>
<%
    // JSON 라이브러리 사용이 여유롭지 않을 경우를 대비해 순수 JSON 문자열로 직접 빌드하거나 아래와 같이 구성할 수 있습니다.
    request.setCharacterEncoding("UTF-8");
    String term = request.getParameter("term");

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    response.setContentType("application/json; charset=UTF-8");
    
    StringBuilder jsonArray = new StringBuilder();
    jsonArray.append("[");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        String sql = "SELECT order_id, product_name FROM work_orders WHERE product_name LIKE ? ORDER BY created_at DESC LIMIT 10";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, "%" + (term != null ? term : "") + "%");
        rs = pstmt.executeQuery();

        boolean first = true;
        while (rs.next()) {
            if (!first) jsonArray.append(",");
            int orderId = rs.getInt("order_id");
            String productName = rs.getString("product_name");
            
            // jQuery UI Autocomplete 규격에 맞게 label, value, orderId 구성
            jsonArray.append("{")
                     .append("\"label\":\"").append(productName).append("\",")
                     .append("\"value\":\"").append(productName).append("\",")
                     .append("\"orderId\":").append(orderId)
                     .append("}");
            first = false;
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }

    jsonArray.append("]");
    out.print(jsonArray.toString());
%>