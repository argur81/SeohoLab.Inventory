<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    // 충진 단계에서 사용한 부자재 이력 조회 (work_order_filling_items)
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    String requestIdStr = request.getParameter("request_id");
    int requestId = 0;
    try {
        if (requestIdStr != null) requestId = Integer.parseInt(requestIdStr.trim());
    } catch (NumberFormatException e) {
        requestId = 0;
    }

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    StringBuilder json = new StringBuilder("[");

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        String sql = "SELECT item_name, subsidiary_type, out_qty FROM work_order_filling_items WHERE request_id = ? ORDER BY filling_item_id ASC";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();

        boolean first = true;
        while (rs.next()) {
            if (!first) json.append(",");
            json.append("{");
            json.append("\"item_name\":\"").append(esc(rs.getString("item_name"))).append("\",");
            json.append("\"subsidiary_type\":\"").append(esc(rs.getString("subsidiary_type"))).append("\",");
            json.append("\"out_qty\":").append(rs.getInt("out_qty"));
            json.append("}");
            first = false;
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }

    json.append("]");
    out.print(json.toString());
%>
<%!
    private String esc(String val) {
        if (val == null) return "";
        return val.replace("\\", "\\\\").replace("\"", "\\\"");
    }
%>
