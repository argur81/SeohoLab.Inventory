<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    // ============================================================
    // [보정] 버튼 처리 (workOrderProgressApproval.jsp)
    // 진행현황을 '수정중'으로 변경 -> workOrderProgressMaking.jsp로 돌아가 재편집
    // ============================================================
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    String requestIdStr = request.getParameter("request_id");
    if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"요청 ID가 누락되었습니다.\"}");
        return;
    }

    int requestId = 0;
    try {
        requestId = Integer.parseInt(requestIdStr.trim());
    } catch (NumberFormatException e) {
        out.print("{\"success\":false,\"message\":\"유효하지 않은 요청 ID입니다.\"}");
        return;
    }

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        String sql = "UPDATE work_order_requests SET progress_status = '수정중' WHERE request_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, requestId);
        int affected = pstmt.executeUpdate();

        if (affected > 0) {
            out.print("{\"success\":true,\"message\":\"보정 처리되었습니다.\"}");
        } else {
            out.print("{\"success\":false,\"message\":\"해당 요청 내역을 찾을 수 없습니다.\"}");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"success\":false,\"message\":\"처리 중 오류가 발생했습니다: " + e.getMessage().replace("\"", "'") + "\"}");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>