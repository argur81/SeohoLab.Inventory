<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    // ============================================================
    // [제조중] 화면 자동저장 (5초마다 클라이언트에서 호출, 조용히 처리)
    // - work_order_making : 헤더 정보 upsert
    // - work_order_making_items : 행별 Lot요약/투입량 delete 후 재삽입
    // - work_order_making_lot_usage : 행×Lot 상세 delete 후 재삽입
    // ============================================================
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    String requestIdStr = request.getParameter("request_id");
    int requestId = 0;
    try {
        if (requestIdStr != null) requestId = Integer.parseInt(requestIdStr.trim());
    } catch (NumberFormatException e) {
        requestId = 0;
    }

    if (requestId <= 0) {
        out.print("{\"success\":false}");
        return;
    }

    String batchNo = request.getParameter("batch_no");
    String dueDate = nullIfEmpty(request.getParameter("due_date"));
    String makerName = request.getParameter("maker_name");
    String mfgDate = nullIfEmpty(request.getParameter("mfg_date"));
    String appearanceResult = request.getParameter("appearance_result");
    String scentResult = request.getParameter("scent_result");
    String specificGravityResult = request.getParameter("specific_gravity_result");
    String phResult = request.getParameter("ph_result");
    double actualQty = parseDouble(request.getParameter("actual_qty"));
    double yieldRateActual = parseDouble(request.getParameter("yield_rate_actual"));

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        conn.setAutoCommit(false);

        // 1. work_order_making 헤더 upsert
        String makingSql = "INSERT INTO work_order_making "
                + "(request_id, batch_no, due_date, maker_name, mfg_date, appearance_result, scent_result, specific_gravity_result, ph_result, actual_qty, yield_rate_actual) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE "
                + "  batch_no = VALUES(batch_no), due_date = VALUES(due_date), maker_name = VALUES(maker_name), "
                + "  mfg_date = VALUES(mfg_date), appearance_result = VALUES(appearance_result), scent_result = VALUES(scent_result), "
                + "  specific_gravity_result = VALUES(specific_gravity_result), ph_result = VALUES(ph_result), "
                + "  actual_qty = VALUES(actual_qty), yield_rate_actual = VALUES(yield_rate_actual), updated_at = CURRENT_TIMESTAMP";
        pstmt = conn.prepareStatement(makingSql);
        pstmt.setInt(1, requestId);
        pstmt.setString(2, batchNo);
        if (dueDate != null) pstmt.setString(3, dueDate); else pstmt.setNull(3, Types.DATE);
        pstmt.setString(4, makerName);
        if (mfgDate != null) pstmt.setString(5, mfgDate); else pstmt.setNull(5, Types.DATE);
        pstmt.setString(6, appearanceResult);
        pstmt.setString(7, scentResult);
        pstmt.setString(8, specificGravityResult);
        pstmt.setString(9, phResult);
        pstmt.setDouble(10, actualQty);
        pstmt.setDouble(11, yieldRateActual);
        pstmt.executeUpdate();
        pstmt.close();

        // 2. work_order_making_items 재구성 (기존 삭제 후 재삽입)
        pstmt = conn.prepareStatement("DELETE FROM work_order_making_items WHERE request_id = ?");
        pstmt.setInt(1, requestId);
        pstmt.executeUpdate();
        pstmt.close();

        int idx = 0;
        String insItemSql = "INSERT INTO work_order_making_items (request_id, item_row_id, lot_numbers, input_qty, input_unit) VALUES (?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(insItemSql);
        while (true) {
            String rowIdStr = request.getParameter("itemRows[" + idx + "].item_row_id");
            if (rowIdStr == null) break;

            int rowId = Integer.parseInt(rowIdStr);
            String lotNumbers = request.getParameter("itemRows[" + idx + "].lot_numbers");
            double inputQty = parseDouble(request.getParameter("itemRows[" + idx + "].input_qty"));
            String inputUnit = request.getParameter("itemRows[" + idx + "].input_unit");
            if (inputUnit == null || inputUnit.trim().isEmpty()) inputUnit = "g";

            pstmt.setInt(1, requestId);
            pstmt.setInt(2, rowId);
            pstmt.setString(3, lotNumbers);
            pstmt.setDouble(4, inputQty);
            pstmt.setString(5, inputUnit);
            pstmt.addBatch();
            idx++;
        }
        if (idx > 0) pstmt.executeBatch();
        pstmt.close();

        // 3. work_order_making_lot_usage 재구성 (기존 삭제 후 재삽입)
        pstmt = conn.prepareStatement("DELETE FROM work_order_making_lot_usage WHERE request_id = ?");
        pstmt.setInt(1, requestId);
        pstmt.executeUpdate();
        pstmt.close();

        int lIdx = 0;
        String insLotSql = "INSERT INTO work_order_making_lot_usage (request_id, item_row_id, lot_number, qty_t, qty_kg, qty_g, qty_mg) VALUES (?, ?, ?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(insLotSql);
        while (true) {
            String rowIdStr = request.getParameter("lotDetails[" + lIdx + "].item_row_id");
            if (rowIdStr == null) break;

            int rowId = Integer.parseInt(rowIdStr);
            String lotNumber = request.getParameter("lotDetails[" + lIdx + "].lot_number");
            double qtyT = parseDouble(request.getParameter("lotDetails[" + lIdx + "].t"));
            double qtyKg = parseDouble(request.getParameter("lotDetails[" + lIdx + "].kg"));
            double qtyG = parseDouble(request.getParameter("lotDetails[" + lIdx + "].g"));
            double qtyMg = parseDouble(request.getParameter("lotDetails[" + lIdx + "].mg"));

            pstmt.setInt(1, requestId);
            pstmt.setInt(2, rowId);
            pstmt.setString(3, lotNumber);
            pstmt.setDouble(4, qtyT);
            pstmt.setDouble(5, qtyKg);
            pstmt.setDouble(6, qtyG);
            pstmt.setDouble(7, qtyMg);
            pstmt.addBatch();
            lIdx++;
        }
        if (lIdx > 0) pstmt.executeBatch();
        pstmt.close();

        conn.commit();
        out.print("{\"success\":true}");

    } catch (Exception e) {
        if (conn != null) { try { conn.rollback(); } catch (Exception ex) {} }
        e.printStackTrace();
        out.print("{\"success\":false}");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>
<%!
    private String nullIfEmpty(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        return s.trim();
    }
    private double parseDouble(String s) {
        if (s == null || s.trim().isEmpty()) return 0.0;
        try { return Double.parseDouble(s.replace(",", "")); } catch (Exception e) { return 0.0; }
    }
%>
