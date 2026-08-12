<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String userId = request.getParameter("user_id");

    if (userId == null || userId.trim().isEmpty()) {
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

        // 외래키 설정이 되어있다면 user_permissions의 권한 데이터가 ON DELETE CASCADE로 함께 삭제됩니다.
        String sql = "DELETE FROM users WHERE user_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId.trim());

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