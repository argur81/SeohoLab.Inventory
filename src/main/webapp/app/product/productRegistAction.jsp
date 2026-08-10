<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. 파라미터 수신 (DB 구조 변경에 따라 lot, 날짜, in_qty 파라미터 제거)
    String productType = request.getParameter("product_type");       // 종류
    String itemName = request.getParameter("item_name");             // 제품명
    String minQtyStr = request.getParameter("min_qty");               // 최소 재고개수

    // 제품명 및 종류 필수값 체크
    if (productType == null || productType.trim().isEmpty()) {
        out.println("<script>alert('종류를 선택해 주세요.'); history.back();</script>");
        return;
    }
    if (itemName == null || itemName.trim().isEmpty()) {
        out.println("<script>alert('제품명을 입력해 주세요.'); history.back();</script>");
        return;
    }

    // 2. 수치 데이터 콤마(,) 제거 및 숫자 파싱 (기본값 0)
    int minQty = 0;
    if (minQtyStr != null && !minQtyStr.trim().isEmpty()) {
        try {
            minQty = Integer.parseInt(minQtyStr.replaceAll(",", "").trim());
        } catch (Exception e) {
            minQty = 0;
        }
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

        // ★ 중복이 없을 경우 INSERT 진행 (변경된 products 테이블 컬럼 적용)
        String sql = "INSERT INTO products ("
                + "category, product_type, item_name, "
                + "stock_qty, min_qty, "
                + "created_at, updated_at) "
                + "VALUES ('PRODUCT', ?, ?, 0, ?, NOW(), NOW())";

        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, productType.trim());
        pstmt.setString(2, itemName.trim());
        pstmt.setInt(3, minQty);

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