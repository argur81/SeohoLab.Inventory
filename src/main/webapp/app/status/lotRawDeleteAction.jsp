<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. 파라미터 수신 (lotId와 연동된 itemId를 함께 받습니다)
    String lotIdStr = request.getParameter("lotId");
    String itemIdStr = request.getParameter("item_id");

    if (lotIdStr == null || lotIdStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }

    int lotId = Integer.parseInt(lotIdStr);
    int itemId = (itemIdStr != null && !itemIdStr.trim().isEmpty()) ? Integer.parseInt(itemIdStr) : 0;

    // 2. DB 연결 설정
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
        
        // 트랜잭션 시작 (재고 차감과 Lot 삭제의 정합성 유지)
        conn.setAutoCommit(false);

        // 3. 삭제하려는 Lot의 재고량 조회 (원료 테이블에서 뺄 재고 확인용)
        double stockT = 0, stockKg = 0, stockG = 0, stockMg = 0;
        String selectSql = "SELECT stock_qty_t, stock_qty_kg, stock_qty_g, stock_qty_mg FROM item_lots WHERE lot_id = ?";
        pstmt = conn.prepareStatement(selectSql);
        pstmt.setInt(1, lotId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            stockT = rs.getDouble("stock_qty_t");
            stockKg = rs.getDouble("stock_qty_kg");
            stockG = rs.getDouble("stock_qty_g");
            stockMg = rs.getDouble("stock_qty_mg");
        }
        rs.close();
        pstmt.close();

        // 4. 원료 마스터 테이블(items) 총 재고에서 해당 Lot의 재고만큼 차감 (-)
        if (itemId > 0) {
            String updateItemSql = "UPDATE items SET stock_qty_t = stock_qty_t - ?, stock_qty_kg = stock_qty_kg - ?, " +
                                   "stock_qty_g = stock_qty_g - ?, stock_qty_mg = stock_qty_mg - ? WHERE item_id = ?";
            pstmt = conn.prepareStatement(updateItemSql);
            pstmt.setDouble(1, stockT);
            pstmt.setDouble(2, stockKg);
            pstmt.setDouble(3, stockG);
            pstmt.setDouble(4, stockMg);
            pstmt.setInt(5, itemId);
            pstmt.executeUpdate();
            pstmt.close();
        }

        // 5. item_lots 테이블에서 해당 Lot 삭제
        String deleteLotSql = "DELETE FROM item_lots WHERE lot_id = ?";
        pstmt = conn.prepareStatement(deleteLotSql);
        pstmt.setInt(1, lotId);
        pstmt.executeUpdate();
        pstmt.close();

        // 커밋
        conn.commit();

        out.println("<script>alert('삭제되었습니다.'); location.href='lotStatusList.jsp';</script>");

    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
        }
        e.printStackTrace();
        out.println("<script>alert('삭제 중 오류가 발생했습니다: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>