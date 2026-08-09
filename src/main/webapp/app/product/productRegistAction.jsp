<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. 파라미터 수신
    String productType = request.getParameter("product_type");       // 종류
    String itemName = request.getParameter("item_name");             // 제품명
    String lotNumber = request.getParameter("lot_number");           // Lot번호
    
    String manufactureDate = request.getParameter("manufacture_date");// 제조일
    String expirationDate = request.getParameter("expiration_date");   // EXP(만료일)
    
    String inQtyStr = request.getParameter("in_qty");                 // 등록개수
    String minQtyStr = request.getParameter("min_qty");               // 최소 재고개수

    // 제품명 필수값 체크
    if (itemName == null || itemName.trim().isEmpty()) {
        out.println("<script>alert('제품명을 입력해 주세요.'); history.back();</script>");
        return;
    }

    // 2. 수치 데이터 콤마(,) 제거 및 숫자 파싱 (기본값 0)
    int inQty = 0;
    int minQty = 0;

    if (inQtyStr != null && !inQtyStr.trim().isEmpty()) {
        inQty = Integer.parseInt(inQtyStr.replaceAll(",", "").trim());
    }
    if (minQtyStr != null && !minQtyStr.trim().isEmpty()) {
        minQty = Integer.parseInt(minQtyStr.replaceAll(",", "").trim());
    }

    // 초기 현재 재고량 = 등록개수 (신규 등록 시)
    int stockQty = inQty;

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

        // ★ [제품 등록 중복 체크] 동일한 제품명이 DB에 존재하는지 사전 검사
        String checkSql = "SELECT COUNT(*) FROM products WHERE item_name = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, itemName.trim());
        rs = pstmt.executeQuery();

        int duplicateCount = 0;
        if (rs.next()) {
            duplicateCount = rs.getInt(1);
        }
        rs.close();
        pstmt.close();

        if (duplicateCount > 0) {
            out.println("<script>alert('이미 등록된 제품명입니다.'); history.back();</script>");
            return;
        }

        // ★ 중복이 없을 경우 INSERT 진행
        String sql = "INSERT INTO products ("
                   + "category, product_type, item_name, lot_number, "
                   + "manufacture_date, expiration_date, "
                   + "in_qty, stock_qty, min_qty, "
                   + "created_at, updated_at) "
                   + "VALUES ('PRODUCT', ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";

        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, productType != null ? productType.trim() : "");
        pstmt.setString(2, itemName.trim());
        pstmt.setString(3, lotNumber != null ? lotNumber.trim() : "");

        // Date 날짜 빈값 예외 처리
        pstmt.setObject(4, (manufactureDate != null && !manufactureDate.trim().isEmpty()) ? Date.valueOf(manufactureDate.trim()) : null);
        pstmt.setObject(5, (expirationDate != null && !expirationDate.trim().isEmpty()) ? Date.valueOf(expirationDate.trim()) : null);

        // 개수 수량 세팅
        pstmt.setInt(6, inQty);
        pstmt.setInt(7, stockQty);
        pstmt.setInt(8, minQty);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('신규 등록이 완료되었습니다.'); location.href='productStockList.jsp';</script>");
        } else {
            out.println("<script>alert('등록에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('등록 중 오류가 발생했습니다: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>