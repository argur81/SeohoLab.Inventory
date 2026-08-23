<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String orderIdStr = request.getParameter("order_id");
    if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
    int orderId = Integer.parseInt(orderIdStr);

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        conn.setAutoCommit(false); // 트랜잭션 시작

        // 1. 하위 원료 항목 삭제
        String delItemsSql = "DELETE FROM work_order_items WHERE order_id = ?";
        pstmt = conn.prepareStatement(delItemsSql);
        pstmt.setInt(1, orderId);
        pstmt.executeUpdate();
        pstmt.close();

        // 2. 하위 제조 방법 항목 삭제
        String delPhasesSql = "DELETE FROM work_order_phases WHERE order_id = ?";
        pstmt = conn.prepareStatement(delPhasesSql);
        pstmt.setInt(1, orderId);
        pstmt.executeUpdate();
        pstmt.close();

        // 3. 상위 제조 지시서 마스터 삭제
        String delOrderSql = "DELETE FROM work_orders WHERE order_id = ?";
        pstmt = conn.prepareStatement(delOrderSql);
        pstmt.setInt(1, orderId);
        pstmt.executeUpdate();

        conn.commit(); // 커밋
%>
        <script>
            alert('삭제되었습니다.');
            location.href = 'workOrderMgmtList.jsp';
        </script>
<%
    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ex) {}
        }
        e.printStackTrace();
%>
        <script>
            alert('삭제 중 오류가 발생했습니다.');
            history.back();
        </script>
<%
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>