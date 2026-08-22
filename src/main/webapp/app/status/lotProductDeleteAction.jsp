<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. 파라미터 수신 (삭제할 lot_id)
    String lotIdStr = request.getParameter("lotId");

    // 2. 유효성 검사
    if (lotIdStr == null || lotIdStr.trim().isEmpty()) {
        out.println("<script>alert('삭제할 데이터 정보가 누락되었습니다.'); history.back();</script>");
        return;
    }

    int lotId = 0;
    try {
        lotId = Integer.parseInt(lotIdStr);
    } catch (NumberFormatException e) {
        out.println("<script>alert('유효하지 않은 ID 형식입니다.'); history.back();</script>");
        return;
    }

    // 3. DB 연결 설정
    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        
        // 트랜잭션 시작 (삭제와 재고 동기화를 안전하게 처리하기 위함)
        conn.setAutoCommit(false);

        // 4-1. 삭제 대상 Lot의 item_name과 stock_qty 먼저 조회
        String selectSql = "SELECT item_name FROM product_lots WHERE lot_id = ?";
        pstmt = conn.prepareStatement(selectSql);
        pstmt.setInt(1, lotId);
        rs = pstmt.executeQuery();

        String itemName = "";
        if (rs.next()) {
            itemName = rs.getString("item_name");
        } else {
            out.println("<script>alert('이미 삭제되었거나 존재하지 않는 데이터입니다.'); location.href='lotStatusList.jsp';</script>");
            return;
        }
        rs.close();
        pstmt.close();

        // 4-2. product_lots 테이블에서 해당 Lot 삭제
        String deleteSql = "DELETE FROM product_lots WHERE lot_id = ?";
        pstmt = conn.prepareStatement(deleteSql);
        pstmt.setInt(1, lotId);
        int result = pstmt.executeUpdate();
        pstmt.close();

        if (result > 0 && itemName != null && !itemName.trim().isEmpty()) {
            // 4-3. 해당 제품(item_name)의 남은 모든 Lot 재고 합계를 구하여 products 테이블의 총 재고(stock_qty) 갱신 (차감 반영)
            String updateStockSql = "UPDATE products SET stock_qty = (SELECT COALESCE(SUM(stock_qty), 0) FROM product_lots WHERE item_name = ?) WHERE item_name = ?";
            pstmt = conn.prepareStatement(updateStockSql);
            pstmt.setString(1, itemName);
            pstmt.setString(2, itemName);
            pstmt.executeUpdate();
            pstmt.close();
        }

        // 커밋 완료
        conn.commit();

        out.println("<script>alert('성공적으로 삭제되었습니다.'); location.href='lotStatusList.jsp';</script>");

    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ex) {}
        }
        e.printStackTrace();
        out.println("<script>alert('데이터베이스 오류가 발생했습니다: " + e.getMessage().replace("'", "") + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch(Exception e) {}
    }
%>