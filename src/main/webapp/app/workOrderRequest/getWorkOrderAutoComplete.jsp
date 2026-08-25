<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String term = request.getParameter("term");

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb?useUnicode=true&characterEncoding=utf8";
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

        // [수정] target_qty와 target_unit도 함께 조회합니다.
        String sql = "SELECT order_id, product_name, target_qty, target_unit FROM work_orders WHERE product_name LIKE ? ORDER BY created_at DESC LIMIT 10";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, "%" + (term != null ? term : "") + "%");
        rs = pstmt.executeQuery();

        boolean first = true;
        while (rs.next()) {
            if (!first) jsonArray.append(",");
            int orderId = rs.getInt("order_id");
            String productName = rs.getString("product_name");
            double targetQty = rs.getDouble("target_qty");
            String targetUnit = rs.getString("target_unit");
            if (targetUnit == null) targetUnit = "kg";

            // 화면에 보여줄 label 형식 지정 (예: 제품명 (지시량: 100.0 kg))
            String displayText = productName + " (지시량: " + targetQty + " " + targetUnit + ")";
            
            jsonArray.append("{")
                     .append("\"label\":\"").append(displayText).append("\",")
                     .append("\"value\":\"").append(productName).append("\",") // 입력창에는 제품명만 들어가게 하려면 value를 productName으로 설정
                     .append("\"orderId\":").append(orderId).append(",")
                     .append("\"targetQty\":").append(targetQty)
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