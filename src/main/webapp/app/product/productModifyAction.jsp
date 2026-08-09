<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. Request 한글 인코딩 설정
    request.setCharacterEncoding("UTF-8");

    // 2. Form 파라미터 수신 (productId, product_id 모두 대응)
    String productIdStr = request.getParameter("productId");
    if (productIdStr == null || productIdStr.trim().isEmpty()) {
        productIdStr = request.getParameter("product_id");
    }
    if (productIdStr == null || productIdStr.trim().isEmpty()) {
        productIdStr = request.getParameter("id");
    }

    String productType = request.getParameter("product_type");
    String itemName = request.getParameter("item_name");
    String lotNumber = request.getParameter("lot_number");
    String manufactureDate = request.getParameter("manufacture_date");
    String expirationDate = request.getParameter("expiration_date");
    
    String inQtyStr = request.getParameter("in_qty");
    String stockQtyStr = request.getParameter("stock_qty");
    String minQtyStr = request.getParameter("min_qty");

    // 3. PK (product_id) 예외 처리
    if (productIdStr == null || productIdStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다. (아이디 누락)'); location.href='productStockList.jsp';</script>");
        return;
    }

    int productId = 0;
    try {
        productId = Integer.parseInt(productIdStr.trim());
    } catch (NumberFormatException e) {
        out.println("<script>alert('유효하지 않은 제품 ID입니다.'); location.href='productStockList.jsp';</script>");
        return;
    }

    // 4. 제품명 필수값 체크
    if (itemName == null || itemName.trim().isEmpty()) {
        out.println("<script>alert('제품명을 입력해 주세요.'); history.back();</script>");
        return;
    }

    // 5. 수량 파라미터 정수(INT) 변환 (천단위 콤마 제거 처리)
    int inQty = 0;
    int stockQty = 0;
    int minQty = 0;

    try {
        if (inQtyStr != null && !inQtyStr.trim().isEmpty()) {
            inQty = Integer.parseInt(inQtyStr.replaceAll(",", "").trim());
        }
        if (stockQtyStr != null && !stockQtyStr.trim().isEmpty()) {
            stockQty = Integer.parseInt(stockQtyStr.replaceAll(",", "").trim());
        }
        if (minQtyStr != null && !minQtyStr.trim().isEmpty()) {
            minQty = Integer.parseInt(minQtyStr.replaceAll(",", "").trim());
        }
    } catch (NumberFormatException e) {
        out.println("<script>alert('수량 항목은 올바른 숫자로 입력해 주세요.'); history.back();</script>");
        return;
    }

    // 6. Cloudtype MariaDB 접속 설정
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

        // ★ [제품 수정 중복 체크] 나 자신(product_id)을 제외한 다른 항목에 동일한 제품명이 있는지 검사
        String checkSql = "SELECT COUNT(*) FROM products WHERE item_name = ? AND product_id != ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, itemName.trim());
        pstmt.setInt(2, productId);
        rs = pstmt.executeQuery();

        int duplicateCount = 0;
        if (rs.next()) {
            duplicateCount = rs.getInt(1);
        }
        rs.close();
        pstmt.close();

        if (duplicateCount > 0) {
            out.println("<script>alert('이미 사용 중인 제품명입니다.'); history.back();</script>");
            return;
        }

        // ★ 화면에서 disabled 처리되어 stockQty가 0으로 넘어왔을 경우 기존 DB 값 유지
        if (stockQty == 0) {
            String checkStockSql = "SELECT stock_qty FROM products WHERE product_id = ?";
            pstmt = conn.prepareStatement(checkStockSql);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                stockQty = rs.getInt("stock_qty");
            }
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        }

        // 7. products 테이블 UPDATE 쿼리 작성
        String sql = "UPDATE products SET "
                + "product_type = ?, "
                + "item_name = ?, "
                + "lot_number = ?, "
                + "manufacture_date = ?, "
                + "expiration_date = ?, "
                + "in_qty = ?, "
                + "stock_qty = ?, "
                + "min_qty = ?, "
                + "updated_at = CURRENT_TIMESTAMP "
                + "WHERE product_id = ?";

        pstmt = conn.prepareStatement(sql);
        
        pstmt.setString(1, productType != null ? productType.trim() : "");
        pstmt.setString(2, itemName.trim());
        pstmt.setString(3, lotNumber != null ? lotNumber.trim() : "");
        
        // 날짜가 빈 값("")일 경우 DB NULL 처리
        if (manufactureDate != null && !manufactureDate.trim().isEmpty()) {
            pstmt.setString(4, manufactureDate.trim());
        } else {
            pstmt.setNull(4, java.sql.Types.DATE);
        }

        if (expirationDate != null && !expirationDate.trim().isEmpty()) {
            pstmt.setString(5, expirationDate.trim());
        } else {
            pstmt.setNull(5, java.sql.Types.DATE);
        }

        // 수량 정보 바인딩
        pstmt.setInt(6, inQty);
        pstmt.setInt(7, stockQty);
        pstmt.setInt(8, minQty);
        pstmt.setInt(9, productId);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('성공적으로 수정되었습니다.'); location.href='productStockList.jsp';</script>");
        } else {
            out.println("<script>alert('수정에 실패했습니다. 다시 시도해 주세요.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('DB 처리 중 오류가 발생했습니다: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>