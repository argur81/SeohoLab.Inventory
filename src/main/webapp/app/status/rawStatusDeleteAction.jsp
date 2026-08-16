<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String itemIdStr = request.getParameter("itemId");
    if (itemIdStr == null || itemIdStr.trim().isEmpty()) {
        itemIdStr = request.getParameter("id");
    }

    int itemId = 0;
    try {
        if (itemIdStr != null && !itemIdStr.trim().isEmpty()) {
            itemId = Integer.parseInt(itemIdStr.trim());
        }
    } catch (NumberFormatException e) {
        itemId = 0;
    }

    if (itemId <= 0) {
        out.println("<script>alert('잘못된 접근입니다. (아이디 누락)'); history.back();</script>");
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

        String sql = "DELETE FROM items WHERE item_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, itemId);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('원료 정보가 삭제되었습니다.'); location.href='rawStatusList.jsp';</script>");
        } else {
            out.println("<script>alert('삭제에 실패했습니다. 존재하지 않는 항목이거나 이미 삭제되었습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('삭제 오류: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>