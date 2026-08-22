<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. 파라미터 수신
    String lotIdStr = request.getParameter("lotId");
    String productType = request.getParameter("product_type");
    String itemName = request.getParameter("item_name");
    String lotNumber = request.getParameter("lot_number");
    String manufactureDate = request.getParameter("manufacture_date");
    String expirationDate = request.getParameter("expiration_date");
    String stockQtyStr = request.getParameter("stock_qty");

    // 2. 유효성 검사
    if (lotIdStr == null || lotIdStr.trim().isEmpty() || productType == null || itemName == null || lotNumber == null || stockQtyStr == null) {
        out.println("<script>alert('필수 입력값이 누락되었습니다.'); history.back();</script>");
        return;
    }

    int lotId = 0;
    int stockQty = 0;
    try {
        lotId = Integer.parseInt(lotIdStr);
        stockQty = Integer.parseInt(stockQtyStr.replace(",", "")); // 콤마 제거
    } catch (NumberFormatException e) {
        out.println("<script>alert('유효하지 않은 숫자 형식입니다.'); history.back();</script>");
        return;
    }

    // 3. DB 연결 설정
    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        
        // 트랜잭션 시작 (두 테이블 모두 안전하게 업데이트하기 위함)
        conn.setAutoCommit(false);

        // 4-1. product_lots 테이블 수정
        String sqlLot = "UPDATE product_lots SET item_name = ?, lot_number = ?, manufacture_date = ?, expiration_date = ?, stock_qty = ?, updated_at = NOW() WHERE lot_id = ?";
        pstmt = conn.prepareStatement(sqlLot);
        pstmt.setString(1, itemName);
        pstmt.setString(2, lotNumber);
        
        if (manufactureDate == null || manufactureDate.trim().isEmpty()) {
            pstmt.setNull(3, Types.DATE);
        } else {
            pstmt.setString(3, manufactureDate);
        }
        
        if (expirationDate == null || expirationDate.trim().isEmpty()) {
            pstmt.setNull(4, Types.DATE);
        } else {
            pstmt.setString(4, expirationDate);
        }
        
        pstmt.setInt(5, stockQty);
        pstmt.setInt(6, lotId);
        pstmt.executeUpdate();
        pstmt.close();

        // 4-2. products 테이블의 product_type(종류) 동기화 업데이트 (필요시)
        String sqlProdType = "UPDATE products SET product_type = ? WHERE item_name = ?";
        pstmt = conn.prepareStatement(sqlProdType);
        pstmt.setString(1, productType);
        pstmt.setString(2, itemName);
        pstmt.executeUpdate();
        pstmt.close();

        // 4-3. 해당 제품(item_name)의 모든 Lot 재고 합계를 구하여 products 테이블의 총 재고(stock_qty) 업데이트
        String sqlSum = "UPDATE products SET stock_qty = (SELECT COALESCE(SUM(stock_qty), 0) FROM product_lots WHERE item_name = ?) WHERE item_name = ?";
        pstmt = conn.prepareStatement(sqlSum);
        pstmt.setString(1, itemName);
        pstmt.setString(2, itemName);
        pstmt.executeUpdate();
        pstmt.close();

        // 커밋
        conn.commit();

        out.println("<script>alert('성공적으로 수정되었습니다.'); location.href='lotStatusList.jsp';</script>");

    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ex) {}
        }
        e.printStackTrace();
        out.println("<script>alert('데이터베이스 오류가 발생했습니다: " + e.getMessage().replace("'", "") + "'); history.back();</script>");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch(Exception e) {}
    }
%>