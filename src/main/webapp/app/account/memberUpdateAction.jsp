<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String userId = request.getParameter("user_id");
    String position = request.getParameter("position");

    if (userId == null || userId.trim().isEmpty() || position == null || position.trim().isEmpty()) {
        out.write("fail:empty");
        return;
    }

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        String sql = "UPDATE users SET position = ? WHERE user_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, position.trim());
        pstmt.setString(2, userId.trim());

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.write("success");
        } else {
            out.write("fail");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.write("error:" + e.getMessage());
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>