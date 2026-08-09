<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. Request 한글 인코딩 설정
    request.setCharacterEncoding("UTF-8");

    // 2. PK 수신 (itemId, item_id, id 파라미터 체크)
    String itemIdStr = request.getParameter("itemId");
    if (itemIdStr == null || itemIdStr.trim().isEmpty()) {
        itemIdStr = request.getParameter("item_id");
    }
    if (itemIdStr == null || itemIdStr.trim().isEmpty()) {
        itemIdStr = request.getParameter("id");
    }

    // 아이디 유효성 검사
    int itemId = 0;
    try {
        if (itemIdStr != null && !itemIdStr.trim().isEmpty()) {
            itemId = Integer.parseInt(itemIdStr.trim());
        }
    } catch (NumberFormatException e) {
        itemId = 0;
    }

    if (itemId <= 0) {
        out.println("<script>alert('잘못된 접근입니다. (아이디 누락)'); history.back();</script>");
        return;
    }

    // 3. Form 파라미터 수신
    String itemName = request.getParameter("item_name");
    String workOrder1 = request.getParameter("work_order_1");
    String workOrder2 = request.getParameter("work_order_2");
    String workOrder3 = request.getParameter("work_order_3");
    
    String lotNumber = request.getParameter("lot_number");
    String receiptDate = request.getParameter("receipt_date");
    String manufactureDate = request.getParameter("manufacture_date");
    String expirationDate = request.getParameter("expiration_date");

    // 현재 재고 수량 파라미터 (t, kg, g, mg 중 입력된 값 수신)
    double stockQtyT = parseDouble(request.getParameter("stock_qty_t"));
    double stockQtyKg = parseDouble(request.getParameter("stock_qty_kg"));
    double stockQtyG = parseDouble(request.getParameter("stock_qty_g"));
    double stockQtyMg = parseDouble(request.getParameter("stock_qty_mg"));

    // 최소 재고 수량 파라미터 (t, kg, g, mg 중 입력된 값 수신)
    double minQtyT = parseDouble(request.getParameter("min_qty_t"));
    double minQtyKg = parseDouble(request.getParameter("min_qty_kg"));
    double minQtyG = parseDouble(request.getParameter("min_qty_g"));
    double minQtyMg = parseDouble(request.getParameter("min_qty_mg"));

    // 4. 수치 단위 완전 동기화 (기준: kg 환산 총량 계산 후 모든 컬럼 맞춰주기)
    double baseStockKg = 0.0;
    if (stockQtyKg > 0) baseStockKg = stockQtyKg;
    else if (stockQtyT > 0) baseStockKg = stockQtyT * 1000.0;
    else if (stockQtyG > 0) baseStockKg = stockQtyG / 1000.0;
    else if (stockQtyMg > 0) baseStockKg = stockQtyMg / 1000000.0;

    stockQtyKg = baseStockKg;
    stockQtyT = baseStockKg / 1000.0;
    stockQtyG = baseStockKg * 1000.0;
    stockQtyMg = baseStockKg * 1000000.0;

    double baseMinKg = 0.0;
    if (minQtyKg > 0) baseMinKg = minQtyKg;
    else if (minQtyT > 0) baseMinKg = minQtyT * 1000.0;
    else if (minQtyG > 0) baseMinKg = minQtyG / 1000.0;
    else if (minQtyMg > 0) baseMinKg = minQtyMg / 1000000.0;

    minQtyKg = baseMinKg;
    minQtyT = baseMinKg / 1000.0;
    minQtyG = baseMinKg * 1000.0;
    minQtyMg = baseMinKg * 1000000.0;

    double totalStockKg = baseStockKg;
    double totalMinKg = baseMinKg;

    // 5. 필수값 검증
    if (itemName == null || itemName.trim().isEmpty()) {
        out.println("<script>alert('원료명을 입력해 주세요.'); history.back();</script>");
        return;
    }

    // 6. DB 접속 및 UPDATE 실행
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

        // ★ [원료 수정 중복 체크] 나 자신(item_id)을 제외한 다른 데이터에 동일 원료명이 있는지 확인
        String checkSql = "SELECT COUNT(*) FROM items WHERE item_name = ? AND item_id != ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, itemName.trim());
        pstmt.setInt(2, itemId);
        rs = pstmt.executeQuery();

        int duplicateCount = 0;
        if (rs.next()) {
            duplicateCount = rs.getInt(1);
        }
        rs.close();
        pstmt.close();

        if (duplicateCount > 0) {
            out.println("<script>alert('이미 사용 중인 원료명입니다.'); history.back();</script>");
            return;
        }

        // ★ 현재 재고가 disabled 등으로 인해 0으로 전송되었을 경우 기존 DB의 stock_qty 유지
        if (totalStockKg == 0.0) {
            String stockSql = "SELECT total_stock_kg, stock_qty_t, stock_qty_kg, stock_qty_g, stock_qty_mg FROM items WHERE item_id = ?";
            pstmt = conn.prepareStatement(stockSql);
            pstmt.setInt(1, itemId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                totalStockKg = rs.getDouble("total_stock_kg");
                stockQtyT = rs.getDouble("stock_qty_t");
                stockQtyKg = rs.getDouble("stock_qty_kg");
                stockQtyG = rs.getDouble("stock_qty_g");
                stockQtyMg = rs.getDouble("stock_qty_mg");
            }
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        }

        // ★ 중복이 없을 경우 UPDATE 진행
        String sql = "UPDATE items SET "
                + "item_name = ?, work_order_1 = ?, work_order_2 = ?, work_order_3 = ?, lot_number = ?, "
                + "receipt_date = ?, manufacture_date = ?, expiration_date = ?, "
                + "stock_qty_t = ?, stock_qty_kg = ?, stock_qty_g = ?, stock_qty_mg = ?, "
                + "min_qty_t = ?, min_qty_kg = ?, min_qty_g = ?, min_qty_mg = ?, "
                + "total_stock_kg = ?, total_min_kg = ?, "
                + "updated_at = CURRENT_TIMESTAMP "
                + "WHERE item_id = ?";

        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, itemName.trim());
        pstmt.setString(2, workOrder1 != null ? workOrder1.trim() : "");
        pstmt.setString(3, workOrder2 != null ? workOrder2.trim() : "");
        pstmt.setString(4, workOrder3 != null ? workOrder3.trim() : "");
        pstmt.setString(5, lotNumber != null ? lotNumber.trim() : "");

        setDateOrNull(pstmt, 6, receiptDate);
        setDateOrNull(pstmt, 7, manufactureDate);
        setDateOrNull(pstmt, 8, expirationDate);

        pstmt.setDouble(9, stockQtyT);
        pstmt.setDouble(10, stockQtyKg);
        pstmt.setDouble(11, stockQtyG);
        pstmt.setDouble(12, stockQtyMg);

        pstmt.setDouble(13, minQtyT);
        pstmt.setDouble(14, minQtyKg);
        pstmt.setDouble(15, minQtyG);
        pstmt.setDouble(16, minQtyMg);

        pstmt.setDouble(17, totalStockKg);
        pstmt.setDouble(18, totalMinKg);

        pstmt.setInt(19, itemId);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('성공적으로 수정되었습니다.'); location.href='rawMaterialStockList.jsp';</script>");
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
    private double parseDouble(String str) {
        if (str == null || str.trim().isEmpty()) return 0.0;
        try { return Double.parseDouble(str.replaceAll(",", "")); } catch (Exception e) { return 0.0; }
    }

    private void setDateOrNull(PreparedStatement pstmt, int index, String dateStr) throws SQLException {
        if (dateStr != null && !dateStr.trim().isEmpty()) pstmt.setString(index, dateStr);
        else pstmt.setNull(index, java.sql.Types.DATE);
    }
%>