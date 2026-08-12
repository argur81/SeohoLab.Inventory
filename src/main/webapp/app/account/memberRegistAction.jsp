<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String userId = request.getParameter("user_id");
    String userPw = request.getParameter("user_pw"); // 임시 비밀번호 받기
    String userName = request.getParameter("user_name");
    String position = request.getParameter("position");

    if (userId == null || userId.trim().isEmpty() || 
        userPw == null || userPw.trim().isEmpty() || 
        userName == null || userName.trim().isEmpty() || 
        position == null || position.trim().isEmpty()) {
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

        // 입력받은 임시 비밀번호(user_pw)를 DB에 저장
        String sql = "INSERT INTO users (user_id, user_pw, user_name, position) VALUES (?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId.trim());
        pstmt.setString(2, userPw.trim());
        pstmt.setString(3, userName.trim());
        pstmt.setString(4, position.trim());

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