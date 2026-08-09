<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. Request 한글 인코딩 설정
    request.setCharacterEncoding("UTF-8");

    // 2. PK 수신 (subsidiary_id, id 파라미터 모두 지원)
    String idStr = request.getParameter("subsidiary_id");
    if (idStr == null || idStr.trim().isEmpty()) {
        idStr = request.getParameter("id");
    }

    int subsidiaryId = 0;
    try {
        if (idStr != null && !idStr.trim().isEmpty()) {
            subsidiaryId = Integer.parseInt(idStr.trim());
        }
    } catch (NumberFormatException e) {
        subsidiaryId = 0;
    }

    if (subsidiaryId <= 0) {
        out.println("<script>alert('잘못된 접근입니다. (아이디 누락)'); history.back();</script>");
        return;
    }

    // 3. Form 파라미터 수신
    String itemName = request.getParameter("item_name");
    String subsidiaryType = request.getParameter("subsidiary_type");
    String materialType = request.getParameter("material_type");

    int minQty = parseInt(request.getParameter("min_qty"));
    int stockQty = parseInt(request.getParameter("stock_qty"));

    // 4. 필수값 검증
    if (itemName == null || itemName.trim().isEmpty()) {
        out.println("<script>alert('자재명을 입력해 주세요.'); history.back();</script>");
        return;
    }

    // 5. DB 접속 정보
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

        // ★ [부자재 수정 중복 체크] 나 자신(subsidiary_id)을 제외한 다른 행 중에서 동일 자재명 검사
        String checkNameSql = "SELECT COUNT(*) FROM subsidiary WHERE item_name = ? AND subsidiary_id != ?";
        pstmt = conn.prepareStatement(checkNameSql);
        pstmt.setString(1, itemName.trim());
        pstmt.setInt(2, subsidiaryId);
        rs = pstmt.executeQuery();

        int duplicateCount = 0;
        if (rs.next()) {
            duplicateCount = rs.getInt(1);
        }
        rs.close();
        pstmt.close();

        if (duplicateCount > 0) {
            out.println("<script>alert('이미 존재하거나 사용 중인 자재명입니다.'); history.back();</script>");
            return;
        }

        // ★ stock_qty가 disabled 등으로 인해 0으로 넘어왔을 경우 기존 DB 값 유지를 위한 체크
        if (stockQty == 0) {
            String checkSql = "SELECT stock_qty FROM subsidiary WHERE subsidiary_id = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, subsidiaryId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                stockQty = rs.getInt("stock_qty");
            }
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        }

        // 6. UPDATE 쿼리 실행
        String sql = "UPDATE subsidiary SET "
                   + "item_name = ?, subsidiary_type = ?, material_type = ?, "
                   + "min_qty = ?, stock_qty = ?, "
                   + "updated_at = CURRENT_TIMESTAMP "
                   + "WHERE subsidiary_id = ?";

        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, itemName.trim());
        pstmt.setString(2, (subsidiaryType != null && !"선택".equals(subsidiaryType)) ? subsidiaryType.trim() : "");
        pstmt.setString(3, (materialType != null && !"선택".equals(materialType)) ? materialType.trim() : "");
        pstmt.setInt(4, minQty);
        pstmt.setInt(5, stockQty);
        pstmt.setInt(6, subsidiaryId);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('부자재 정보가 성공적으로 수정되었습니다.'); location.href='subsidiaryStockList.jsp';</script>");
        } else {
            out.println("<script>alert('수정에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('수정 중 오류 발생: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>

<%!
    // 숫자에 콤마(,)가 포함되어 넘어오는 경우를 대비한 정수 파싱 함수
    private int parseInt(String str) {
        if (str == null || str.trim().isEmpty()) return 0;
        try {
            return Integer.parseInt(str.replaceAll(",", "").trim());
        } catch (Exception e) {
            return 0;
        }
    }
%>