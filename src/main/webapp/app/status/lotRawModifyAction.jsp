<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. 파라미터 수신
    String lotIdStr = request.getParameter("lotId");
    String itemIdStr = request.getParameter("item_id");
    String lotNumber = request.getParameter("lot_number");
    
    // 날짜 값 처리 (빈 값이면 null로 설정)
    String receiptDate = request.getParameter("receipt_date");
    if (receiptDate == null || receiptDate.trim().isEmpty()) receiptDate = null;

    String manufactureDate = request.getParameter("manufacture_date");
    if (manufactureDate == null || manufactureDate.trim().isEmpty()) manufactureDate = null;

    String expirationDate = request.getParameter("expiration_date");
    if (expirationDate == null || expirationDate.trim().isEmpty()) expirationDate = null;

    // 수정된 무게 값 수신 (값이 없거나 공백이면 0으로 처리)
    String tStr = request.getParameter("stock_qty_t");
    String kgStr = request.getParameter("stock_qty_kg");
    String gStr = request.getParameter("stock_qty_g");
    String mgStr = request.getParameter("stock_qty_mg");

    double newT = (tStr != null && !tStr.trim().isEmpty()) ? Double.parseDouble(tStr) : 0;
    double newKg = (kgStr != null && !kgStr.trim().isEmpty()) ? Double.parseDouble(kgStr) : 0;
    double newG = (gStr != null && !gStr.trim().isEmpty()) ? Double.parseDouble(gStr) : 0;
    double newMg = (mgStr != null && !mgStr.trim().isEmpty()) ? Double.parseDouble(mgStr) : 0;

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
        
        // 트랜잭션 시작
        conn.setAutoCommit(false);

        // 3. 수정 전 기존 Lot의 재고량 조회 (차이 계산용)
        double oldT = 0, oldKg = 0, oldG = 0, oldMg = 0;
        String selectSql = "SELECT stock_qty_t, stock_qty_kg, stock_qty_g, stock_qty_mg FROM item_lots WHERE lot_id = ?";
        pstmt = conn.prepareStatement(selectSql);
        pstmt.setInt(1, lotId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            oldT = rs.getDouble("stock_qty_t");
            oldKg = rs.getDouble("stock_qty_kg");
            oldG = rs.getDouble("stock_qty_g");
            oldMg = rs.getDouble("stock_qty_mg");
        }
        rs.close();
        pstmt.close();

        // 4. item_lots 테이블 업데이트
        String updateLotSql = "UPDATE item_lots SET lot_number = ?, receipt_date = ?, manufacture_date = ?, expiration_date = ?, " +
                              "stock_qty_t = ?, stock_qty_kg = ?, stock_qty_g = ?, stock_qty_mg = ? WHERE lot_id = ?";
        pstmt = conn.prepareStatement(updateLotSql);
        pstmt.setString(1, lotNumber);
        
        if (receiptDate != null) pstmt.setString(2, receiptDate); else pstmt.setNull(2, java.sql.Types.DATE);
        if (manufactureDate != null) pstmt.setString(3, manufactureDate); else pstmt.setNull(3, java.sql.Types.DATE);
        if (expirationDate != null) pstmt.setString(4, expirationDate); else pstmt.setNull(4, java.sql.Types.DATE);

        pstmt.setDouble(5, newT);
        pstmt.setDouble(6, newKg);
        pstmt.setDouble(7, newG);
        pstmt.setDouble(8, newMg);
        pstmt.setInt(9, lotId);
        pstmt.executeUpdate();
        pstmt.close();

        // 5. [추가됨] 원료 마스터 테이블(items) 재고 연동 (수정 전후 차이만큼 반영)
        if (itemId > 0) {
            double diffT = newT - oldT;
            double diffKg = newKg - oldKg;
            double diffG = newG - oldG;
            double diffMg = newMg - oldMg;

            String updateItemSql = "UPDATE items SET stock_qty_t = stock_qty_t + ?, stock_qty_kg = stock_qty_kg + ?, " +
                                "stock_qty_g = stock_qty_g + ?, stock_qty_mg = stock_qty_mg + ? WHERE item_id = ?";
            pstmt = conn.prepareStatement(updateItemSql);
            pstmt.setDouble(1, diffT);
            pstmt.setDouble(2, diffKg);
            pstmt.setDouble(3, diffG);
            pstmt.setDouble(4, diffMg);
            pstmt.setInt(5, itemId);
            pstmt.executeUpdate();
            pstmt.close();
        }

        // 커밋
        conn.commit();

        out.println("<script>alert('성공적으로 수정되었습니다.'); location.href='lotStatusList.jsp';</script>");

    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
        }
        e.printStackTrace();
        out.println("<script>alert('수정 중 오류가 발생했습니다: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>