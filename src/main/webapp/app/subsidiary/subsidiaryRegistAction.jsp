<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 한글 파라미터 인코딩 설정
    request.setCharacterEncoding("UTF-8");

    // 1. 폼 파라미터 수신
    String category = request.getParameter("category");
    if (category == null || category.trim().isEmpty()) {
        category = "SUBSIDIARY";
    }

    String subsidiaryType = request.getParameter("subsidiary_type");
    String itemName = request.getParameter("item_name");
    String materialType = request.getParameter("material_type");
    String inQtyStr = request.getParameter("in_qty");
    String minQtyStr = request.getParameter("min_qty");

    // 2. 자재명 필수값 체크
    if (itemName == null || itemName.trim().isEmpty()) {
        out.println("<script>alert('자재명을 입력해 주세요.'); history.back();</script>");
        return;
    }

    // 3. 수량 파라미터 숫자 변환 (콤마 제거 및 예외 처리)
    int inQty = 0;
    int minQty = 0;

    try {
        if (inQtyStr != null && !inQtyStr.trim().isEmpty()) {
            inQty = Integer.parseInt(inQtyStr.replaceAll(",", ""));
        }
        if (minQtyStr != null && !minQtyStr.trim().isEmpty()) {
            minQty = Integer.parseInt(minQtyStr.replaceAll(",", ""));
        }
    } catch (NumberFormatException e) {
        out.println("<script>alert('수량은 올바른 숫자로 입력해 주세요.'); history.back();</script>");
        return;
    }

    // 신규 등록 시 등록개수가 현재 재고 개수가 됨
    int stockQty = inQty;

    // 4. DB 연결 정보
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

        // ★ [부자재 등록 중복 체크] 동일한 자재명이 DB에 존재하는지 사전 검사
        String checkSql = "SELECT COUNT(*) FROM subsidiary WHERE item_name = ?";
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
            out.println("<script>alert('이미 등록된 자재명입니다.'); history.back();</script>");
            return;
        }

        // ★ 중복이 없을 경우 5. INSERT 쿼리 실행
        String sql = "INSERT INTO subsidiary "
                + "(category, subsidiary_type, item_name, material_type, in_qty, stock_qty, min_qty, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, category);
        pstmt.setString(2, subsidiaryType != null ? subsidiaryType : "");
        pstmt.setString(3, itemName.trim());
        pstmt.setString(4, materialType != null ? materialType : "");
        pstmt.setInt(5, inQty);
        pstmt.setInt(6, stockQty);
        pstmt.setInt(7, minQty);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('신규 등록이 완료되었습니다.'); location.href='subsidiaryStockList.jsp';</script>");
        } else {
            out.println("<script>alert('등록에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('등록 중 오류가 발생했습니다.: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>