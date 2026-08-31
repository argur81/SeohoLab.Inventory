<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
    response.setCharacterEncoding("UTF-8");

    String requestIdStr = request.getParameter("request_id");
    if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
    int requestId = Integer.parseInt(requestIdStr);

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        conn.setAutoCommit(false); // 트랜잭션 시작

        // progress_status를 '생산완료'로 업데이트
        String updateStatusSql = "UPDATE work_order_requests SET progress_status = '생산완료', updated_at = CURRENT_TIMESTAMP WHERE request_id = ?";
        pstmt = conn.prepareStatement(updateStatusSql);
        pstmt.setInt(1, requestId);
        int result = pstmt.executeUpdate();

        if (result > 0) {
            conn.commit();
            out.println("<script>alert('충진이 완료되어 상태가 생산완료로 변경되었습니다.'); location.href='workOrderProgressList.jsp';</script>");
        } else {
            conn.rollback();
            out.println("<script>alert('처리 실패: 지시서 정보를 찾을 수 없습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch(SQLException ignored) {}
        }
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>