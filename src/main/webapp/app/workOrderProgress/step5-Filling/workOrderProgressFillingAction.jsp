<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // ============================================================
    // [충진완료] 버튼 처리
    // 1. production_qty(생산수량)만큼 products 총재고 증가
    // 2. product_lots에 제조번호(work_order_making.batch_no) 기준 Lot 재고 반영
    // 3. work_order_filling_report / work_order_filling_items 에 포장 지시 및
    //    기록서 전체 입력값 저장 (step6-Done 조회용)
    // 4. work_order_requests.progress_status 를 '생산완료'로 변경
    // 5. 처리 완료 후 step6-Done/workOrderProgressDone.jsp 로 이동
    // ※ 부자재(work_order_subsidiary)는 step4(제조완료)에서 이미 예상사용량이
    //   기록되어 있으며, 실입고/실사용 확정 전이므로 이 단계에서 재고를 차감하지 않는다.
    // ※ 이미 '생산완료' 상태인 건은 재적용하지 않도록 가드 처리
    // ============================================================
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
    response.setCharacterEncoding("UTF-8");

    String loginUserId = (String) session.getAttribute("userId");
    if (loginUserId == null || loginUserId.trim().isEmpty()) {
        loginUserId = (String) session.getAttribute("loginId");
    }

    String requestIdStr = request.getParameter("request_id");
    if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
    int requestId = Integer.parseInt(requestIdStr);

    String productionQtyStr = request.getParameter("production_qty");
    int productionQty = 0;
    try {
        if (productionQtyStr != null && !productionQtyStr.trim().isEmpty()) {
            productionQty = Integer.parseInt(productionQtyStr.replace(",", "").trim());
        }
    } catch (Exception e) {
        productionQty = 0;
    }

    if (productionQty <= 0) {
        out.println("<script>alert('생산수량을 올바르게 입력해 주세요.'); history.back();</script>");
        return;
    }

    String manufactureDate = request.getParameter("manufacture_date");
    String expirationDate = request.getParameter("expiration_date");

    // ── 포장 지시 및 기록서 헤더 파라미터 ──
    String workDate = nullIfEmpty(request.getParameter("work_date"));
    int orderQtyEa = parseIntSafe(request.getParameter("order_qty_ea"));
    double mfgInputQty = parseDoubleSafe(request.getParameter("mfg_input_qty"));

    String item1Result = request.getParameter("item1");
    String item1Reason = request.getParameter("item1_reason");
    String item1Remark = request.getParameter("item1_remark");
    String item2Result = request.getParameter("item2");
    String item2Reason = request.getParameter("item2_reason");
    String item2Remark = request.getParameter("item2_remark");
    String item3Result = request.getParameter("item3");
    String item3Reason = request.getParameter("item3_reason");
    String item3Remark = request.getParameter("item3_remark");
    String item4Result = request.getParameter("item4");
    String item4Reason = request.getParameter("item4_reason");
    String item4Remark = request.getParameter("item4_remark");

    double workHours = parseDoubleSafe(request.getParameter("work_hours"));
    int workPersonCount = parseIntSafe(request.getParameter("work_person_count"));
    double mfgQtyKg = parseDoubleSafe(request.getParameter("mfg_qty_kg"));
    double producedQtyKg = parseDoubleSafe(request.getParameter("produced_qty_kg"));
    int statusOrderQtyEa = parseIntSafe(request.getParameter("status_order_qty_ea"));
    int wasteQty = parseIntSafe(request.getParameter("waste_qty"));
    int releaseQty = parseIntSafe(request.getParameter("release_qty"));
    double yieldRate = parseDoubleSafe(request.getParameter("yield_rate"));
    double defectRate = parseDoubleSafe(request.getParameter("defect_rate"));
    String writerName = request.getParameter("writer_name");
    String verdict = request.getParameter("verdict");
    if (verdict == null || verdict.trim().isEmpty()) verdict = "적합";

    // ── 포장재 투입 행 (work_content[] / machine_name[] / item_name[] / subsidiary_type[] / out_qty[] / worker_name[] / defect_qty[]) ──
    String[] workContents = request.getParameterValues("work_content[]");
    String[] machineNames = request.getParameterValues("machine_name[]");
    String[] itemNames = request.getParameterValues("item_name[]");
    String[] subsidiaryTypes = request.getParameterValues("subsidiary_type[]");
    String[] outQtys = request.getParameterValues("out_qty[]");
    String[] workerNames = request.getParameterValues("worker_name[]");
    String[] defectQtys = request.getParameterValues("defect_qty[]");

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        conn.setAutoCommit(false);

        // 0. 이미 생산완료 처리된 건인지 확인 (중복 재고증가 방지) + 제품명 확보
        String checkSql = "SELECT product_name, progress_status FROM work_order_requests WHERE request_id = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();

        String productName = "";
        String currentStatus = "";
        if (rs.next()) {
            productName = rs.getString("product_name");
            currentStatus = rs.getString("progress_status") != null ? rs.getString("progress_status") : "";
        } else {
            conn.rollback();
            out.println("<script>alert('해당 요청 내역을 찾을 수 없습니다.'); history.back();</script>");
            return;
        }
        rs.close();
        pstmt.close();

        if ("생산완료".equals(currentStatus)) {
            conn.rollback();
            out.println("<script>alert('이미 생산완료 처리된 항목입니다.'); location.href='../step6-Done/workOrderProgressDone.jsp?request_id=" + requestId + "';</script>");
            return;
        }

        if (productName == null || productName.trim().isEmpty()) {
            conn.rollback();
            out.println("<script>alert('제품명 정보를 확인할 수 없습니다.'); history.back();</script>");
            return;
        }

        // 1. 제조번호(Lot) 조회 (work_order_making.batch_no) - 완제품 Lot번호로 그대로 사용
        String batchNo = "";
        String batchSql = "SELECT batch_no FROM work_order_making WHERE request_id = ?";
        pstmt = conn.prepareStatement(batchSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            batchNo = rs.getString("batch_no");
        }
        rs.close();
        pstmt.close();
        if (batchNo == null || batchNo.trim().isEmpty()) {
            batchNo = "NO_LOT";
        }

        // 2. products 총재고 증가 (미리 등록되어 있는 제품이어야 함 - productRegist.jsp에서 신규등록)
        String updateProductSql = "UPDATE products SET stock_qty = stock_qty + ?, last_stock_user_id = ?, updated_at = CURRENT_TIMESTAMP WHERE TRIM(item_name) = ?";
        pstmt = conn.prepareStatement(updateProductSql);
        pstmt.setInt(1, productionQty);
        pstmt.setString(2, loginUserId);
        pstmt.setString(3, productName.trim());
        int productUpdateResult = pstmt.executeUpdate();
        pstmt.close();

        if (productUpdateResult == 0) {
            // 등록되지 않은 제품이면 자동으로 신규 등록 (종류는 기본값 '기타'로 생성, 추후 productModify.jsp에서 수정 가능)
            String insertProductSql = "INSERT INTO products (category, product_type, item_name, stock_qty, min_qty, last_stock_user_id) "
                    + "VALUES ('PRODUCT', '기타', ?, ?, 0, ?)";
            pstmt = conn.prepareStatement(insertProductSql);
            pstmt.setString(1, productName.trim());
            pstmt.setInt(2, productionQty);
            pstmt.setString(3, loginUserId);
            pstmt.executeUpdate();
            pstmt.close();
        }

        // 3. product_lots Lot별 재고 반영 (같은 Lot이 이미 있으면 수량 합산)
        String lotSql = "INSERT INTO product_lots (item_name, lot_number, manufacture_date, expiration_date, stock_qty) "
                + "VALUES (?, ?, NULLIF(?, ''), NULLIF(?, ''), ?) "
                + "ON DUPLICATE KEY UPDATE "
                + "  stock_qty = stock_qty + VALUES(stock_qty), "
                + "  manufacture_date = COALESCE(VALUES(manufacture_date), manufacture_date), "
                + "  expiration_date = COALESCE(VALUES(expiration_date), expiration_date), "
                + "  updated_at = CURRENT_TIMESTAMP";
        pstmt = conn.prepareStatement(lotSql);
        pstmt.setString(1, productName.trim());
        pstmt.setString(2, batchNo.trim());
        pstmt.setString(3, manufactureDate);
        pstmt.setString(4, expirationDate);
        pstmt.setInt(5, productionQty);
        pstmt.executeUpdate();
        pstmt.close();

        // 4. work_order_filling_report 저장 (upsert)
        String reportSql = "INSERT INTO work_order_filling_report "
                + "(request_id, work_date, order_qty_ea, mfg_input_qty, "
                + " item1_result, item1_reason, item1_remark, item2_result, item2_reason, item2_remark, "
                + " item3_result, item3_reason, item3_remark, item4_result, item4_reason, item4_remark, "
                + " work_hours, work_person_count, mfg_qty_kg, produced_qty_kg, status_order_qty_ea, "
                + " production_qty, waste_qty, release_qty, yield_rate, defect_rate, writer_name, verdict) "
                + "VALUES (?, NULLIF(?, ''), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE "
                + "  work_date = VALUES(work_date), order_qty_ea = VALUES(order_qty_ea), mfg_input_qty = VALUES(mfg_input_qty), "
                + "  item1_result = VALUES(item1_result), item1_reason = VALUES(item1_reason), item1_remark = VALUES(item1_remark), "
                + "  item2_result = VALUES(item2_result), item2_reason = VALUES(item2_reason), item2_remark = VALUES(item2_remark), "
                + "  item3_result = VALUES(item3_result), item3_reason = VALUES(item3_reason), item3_remark = VALUES(item3_remark), "
                + "  item4_result = VALUES(item4_result), item4_reason = VALUES(item4_reason), item4_remark = VALUES(item4_remark), "
                + "  work_hours = VALUES(work_hours), work_person_count = VALUES(work_person_count), "
                + "  mfg_qty_kg = VALUES(mfg_qty_kg), produced_qty_kg = VALUES(produced_qty_kg), status_order_qty_ea = VALUES(status_order_qty_ea), "
                + "  production_qty = VALUES(production_qty), waste_qty = VALUES(waste_qty), release_qty = VALUES(release_qty), "
                + "  yield_rate = VALUES(yield_rate), defect_rate = VALUES(defect_rate), writer_name = VALUES(writer_name), "
                + "  verdict = VALUES(verdict), updated_at = CURRENT_TIMESTAMP";
        pstmt = conn.prepareStatement(reportSql);
        pstmt.setInt(1, requestId);
        pstmt.setString(2, workDate);
        pstmt.setInt(3, orderQtyEa);
        pstmt.setDouble(4, mfgInputQty);
        pstmt.setString(5, item1Result != null ? item1Result : "적합");
        pstmt.setString(6, item1Reason);
        pstmt.setString(7, item1Remark);
        pstmt.setString(8, item2Result != null ? item2Result : "적합");
        pstmt.setString(9, item2Reason);
        pstmt.setString(10, item2Remark);
        pstmt.setString(11, item3Result != null ? item3Result : "적합");
        pstmt.setString(12, item3Reason);
        pstmt.setString(13, item3Remark);
        pstmt.setString(14, item4Result != null ? item4Result : "적합");
        pstmt.setString(15, item4Reason);
        pstmt.setString(16, item4Remark);
        pstmt.setDouble(17, workHours);
        pstmt.setInt(18, workPersonCount);
        pstmt.setDouble(19, mfgQtyKg);
        pstmt.setDouble(20, producedQtyKg);
        pstmt.setInt(21, statusOrderQtyEa);
        pstmt.setInt(22, productionQty);
        pstmt.setInt(23, wasteQty);
        pstmt.setInt(24, releaseQty);
        pstmt.setDouble(25, yieldRate);
        pstmt.setDouble(26, defectRate);
        pstmt.setString(27, writerName);
        pstmt.setString(28, verdict);
        pstmt.executeUpdate();
        pstmt.close();

        // 5. work_order_filling_items 재구성 (기존 삭제 후 재삽입)
        String deleteItemsSql = "DELETE FROM work_order_filling_items WHERE request_id = ?";
        pstmt = conn.prepareStatement(deleteItemsSql);
        pstmt.setInt(1, requestId);
        pstmt.executeUpdate();
        pstmt.close();

        if (itemNames != null) {
            String insertItemSql = "INSERT INTO work_order_filling_items "
                    + "(request_id, row_no, work_content, machine_name, item_name, subsidiary_type, out_qty, worker_name, defect_qty) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(insertItemSql);

            int validRowNo = 0;
            for (int i = 0; i < itemNames.length; i++) {
                String iName = itemNames[i];
                if (iName == null || iName.trim().isEmpty()) continue; // 비어있는 행(미사용)은 저장하지 않음

                validRowNo++;
                String wContent = (workContents != null && i < workContents.length) ? workContents[i] : "";
                String mName = (machineNames != null && i < machineNames.length) ? machineNames[i] : "";
                String sType = (subsidiaryTypes != null && i < subsidiaryTypes.length) ? subsidiaryTypes[i] : "";
                int oQty = (outQtys != null && i < outQtys.length) ? parseIntSafe(outQtys[i]) : 0;
                String wName = (workerNames != null && i < workerNames.length) ? workerNames[i] : "";
                int dQty = (defectQtys != null && i < defectQtys.length) ? parseIntSafe(defectQtys[i]) : 0;

                pstmt.setInt(1, requestId);
                pstmt.setInt(2, validRowNo);
                pstmt.setString(3, wContent);
                pstmt.setString(4, mName);
                pstmt.setString(5, iName.trim());
                pstmt.setString(6, sType);
                pstmt.setInt(7, oQty);
                pstmt.setString(8, wName);
                pstmt.setInt(9, dQty);
                pstmt.addBatch();
            }
            if (validRowNo > 0) pstmt.executeBatch();
            pstmt.close();
        }

        // 6. 진행현황을 생산완료로 변경
        String updateStatusSql = "UPDATE work_order_requests SET progress_status = '생산완료', updated_at = CURRENT_TIMESTAMP WHERE request_id = ?";
        pstmt = conn.prepareStatement(updateStatusSql);
        pstmt.setInt(1, requestId);
        pstmt.executeUpdate();
        pstmt.close();

        conn.commit();
        out.println("<script>alert('생산이 완료되어 제품 재고(총재고 및 Lot)에 반영되었습니다.'); location.href='../step6-Done/workOrderProgressDone.jsp?request_id=" + requestId + "';</script>");

    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch(SQLException ignored) {}
        }
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>
<%!
    private String nullIfEmpty(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        return s.trim();
    }
    private int parseIntSafe(String s) {
        if (s == null || s.trim().isEmpty()) return 0;
        try { return Integer.parseInt(s.replace(",", "").trim()); } catch (Exception e) { return 0; }
    }
    private double parseDoubleSafe(String s) {
        if (s == null || s.trim().isEmpty()) return 0.0;
        try { return Double.parseDouble(s.replace(",", "").trim()); } catch (Exception e) { return 0.0; }
    }
%>
