<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // ============================================================
    // [승인 / 제조완료] 처리  (위치: step4-Complete/workOrderProgressCompleteAction.jsp)
    // 1. work_order_making_lot_usage (실제 사용한 Lot/수량) 기준으로 item_lots 재고 차감
    // 2. ★ Lot을 선택하지 않고 투입량만 직접 입력한 행(work_order_making_items)은
    //      - 해당 원료의 보유 Lot 개수로 균등 분배하여 각 Lot에서 차감
    //      - 보유 Lot이 하나도 없으면 원료 총재고(items)만 차감 (마이너스 재고 허용)
    // 3. items (원료 총재고) 차감 (Lot별 사용량 + 직접입력 사용량 합계)
    // 4. work_order_requests.progress_status 를 '제조완료'로 변경
    // ※ 이미 '제조완료' 상태인 건은 재차감하지 않도록 가드 처리
    // ============================================================
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    String loginUserId = (String) session.getAttribute("userId");
    if (loginUserId == null || loginUserId.trim().isEmpty()) {
        loginUserId = (String) session.getAttribute("loginId");
    }

    String requestIdStr = request.getParameter("request_id");
    if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"요청 ID가 누락되었습니다.\"}");
        return;
    }

    int requestId = 0;
    try {
        requestId = Integer.parseInt(requestIdStr.trim());
    } catch (NumberFormatException e) {
        out.print("{\"success\":false,\"message\":\"유효하지 않은 요청 ID입니다.\"}");
        return;
    }

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

        // 0. 이미 완료 처리된 건인지 확인 (중복 차감 방지)
        String checkSql = "SELECT progress_status FROM work_order_requests WHERE request_id = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();

        String currentStatus = "";
        if (rs.next()) {
            currentStatus = rs.getString("progress_status") != null ? rs.getString("progress_status") : "";
        } else {
            conn.rollback();
            out.print("{\"success\":false,\"message\":\"해당 요청 내역을 찾을 수 없습니다.\"}");
            return;
        }
        rs.close();
        pstmt.close();

        if ("제조완료".equals(currentStatus)) {
            conn.rollback();
            out.print("{\"success\":true,\"message\":\"이미 제조완료 처리된 항목입니다.\"}");
            return;
        }

        // 1. 실제 사용한 Lot별 사용량 조회 (원료명은 저장 시점에 직접 기록되어 있어 JOIN 불필요)
        String lotUsageSql = "SELECT item_row_id, lot_number, qty_t, qty_kg, qty_g, qty_mg, raw_material_name "
                + "FROM work_order_making_lot_usage WHERE request_id = ?";
        pstmt = conn.prepareStatement(lotUsageSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();

        // 원료명별 총 차감량 누적 (items 테이블 갱신용)
        Map<String, double[]> itemTotalMap = new LinkedHashMap<String, double[]>(); // [t, kg, g, mg]
        // Lot을 선택해서 이미 Lot 차감이 잡힌 행 (직접입력 차감 대상에서 제외하기 위함)
        Set<Integer> rowsWithLot = new HashSet<Integer>();

        String lotUpdateSql = "UPDATE item_lots SET "
                + "  stock_qty_t = stock_qty_t - ?, "
                + "  stock_qty_kg = stock_qty_kg - ?, "
                + "  stock_qty_g = stock_qty_g - ?, "
                + "  stock_qty_mg = stock_qty_mg - ?, "
                + "  updated_at = CURRENT_TIMESTAMP "
                + "WHERE TRIM(lot_number) = ? AND TRIM(item_name) = ?";
        PreparedStatement pstmtLot = conn.prepareStatement(lotUpdateSql);

        int usageCount = 0;
        while (rs.next()) {
            String rawMaterialName = rs.getString("raw_material_name");
            if (rawMaterialName == null || rawMaterialName.trim().isEmpty()) continue;

            String lotNumber = rs.getString("lot_number");
            double t = rs.getDouble("qty_t");
            double kg = rs.getDouble("qty_kg");
            double g = rs.getDouble("qty_g");
            double mg = rs.getDouble("qty_mg");

            if (t == 0 && kg == 0 && g == 0 && mg == 0) continue;

            rowsWithLot.add(rs.getInt("item_row_id"));

            // 1-1. 해당 Lot 재고 차감
            pstmtLot.setDouble(1, t);
            pstmtLot.setDouble(2, kg);
            pstmtLot.setDouble(3, g);
            pstmtLot.setDouble(4, mg);
            pstmtLot.setString(5, lotNumber != null ? lotNumber.trim() : "");
            pstmtLot.setString(6, rawMaterialName.trim());
            pstmtLot.addBatch();
            usageCount++;

            // 1-2. 원료명별 총 사용량 누적 (지시서 원료 + 제조중 추가원료 모두 동일하게 합산)
            addToItemTotal(itemTotalMap, rawMaterialName.trim(), t, kg, g, mg);
        }
        rs.close();
        pstmt.close();

        if (usageCount > 0) {
            pstmtLot.executeBatch();
        }
        pstmtLot.close();

        // 1-3. ★ Lot 없이 투입량만 직접 입력한 행 처리
        deductManualInputs(conn, requestId, rowsWithLot, itemTotalMap);

        // 2. items(원료 마스터) 총재고에서 원료명별 총 사용량만큼 차감
        if (!itemTotalMap.isEmpty()) {
            String itemUpdateSql = "UPDATE items SET "
                    + "  stock_qty_t = stock_qty_t - ?, "
                    + "  stock_qty_kg = stock_qty_kg - ?, "
                    + "  stock_qty_g = stock_qty_g - ?, "
                    + "  stock_qty_mg = stock_qty_mg - ?, "
                    + "  last_stock_user_id = ?, "
                    + "  updated_at = CURRENT_TIMESTAMP "
                    + "WHERE TRIM(item_name) = ?";
            PreparedStatement pstmtItem = conn.prepareStatement(itemUpdateSql);

            for (Map.Entry<String, double[]> entry : itemTotalMap.entrySet()) {
                double[] sums = entry.getValue();
                pstmtItem.setDouble(1, sums[0]);
                pstmtItem.setDouble(2, sums[1]);
                pstmtItem.setDouble(3, sums[2]);
                pstmtItem.setDouble(4, sums[3]);
                pstmtItem.setString(5, loginUserId);
                pstmtItem.setString(6, entry.getKey());
                pstmtItem.addBatch();
            }
            pstmtItem.executeBatch();
            pstmtItem.close();
        }

        // 3. 진행현황을 제조완료로 변경
        String updateStatusSql = "UPDATE work_order_requests SET progress_status = '제조완료' WHERE request_id = ?";
        pstmt = conn.prepareStatement(updateStatusSql);
        pstmt.setInt(1, requestId);
        pstmt.executeUpdate();
        pstmt.close();

        conn.commit();
        out.print("{\"success\":true,\"message\":\"제조완료 처리되었습니다. (원료 재고가 차감되었습니다)\"}");

    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ex) {}
        }
        e.printStackTrace();
        out.print("{\"success\":false,\"message\":\"처리 중 오류가 발생했습니다: " + e.getMessage().replace("\"", "'") + "\"}");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>
<%!
    // 원료명별 총 차감량 누적 [t, kg, g, mg]
    private void addToItemTotal(Map<String, double[]> map, String name, double t, double kg, double g, double mg) {
        double[] sums = map.get(name);
        if (sums == null) {
            sums = new double[]{0, 0, 0, 0};
            map.put(name, sums);
        }
        sums[0] += t; sums[1] += kg; sums[2] += g; sums[3] += mg;
    }

    // Lot을 선택하지 않고 투입량만 입력한 행의 재고 차감
    //  - 해당 원료의 보유 Lot 개수(N)로 균등 분배하여 각 Lot에서 (투입량 / N) 차감
    //  - 보유 Lot이 없으면 Lot 차감 없이 총재고(items)만 차감 → 마이너스 재고
    //  - 재고 컬럼(t/kg/g/mg)은 모두 같은 양을 단위만 달리 보관하므로 4개 컬럼을 같은 양으로 환산해 차감
    private void deductManualInputs(Connection conn, int requestId, Set<Integer> rowsWithLot,
                                    Map<String, double[]> itemTotalMap) throws SQLException {
        List<Object[]> manualRows = new ArrayList<Object[]>(); // {원료명, 투입량(g)}

        PreparedStatement ps = conn.prepareStatement(
                "SELECT item_row_id, raw_material_name, input_qty, input_unit "
              + "FROM work_order_making_items WHERE request_id = ?");
        ps.setInt(1, requestId);
        ResultSet r = ps.executeQuery();
        while (r.next()) {
            int rowId = r.getInt("item_row_id");
            if (rowsWithLot.contains(rowId)) continue; // Lot 선택 행은 이미 Lot 기준으로 차감됨

            String name = r.getString("raw_material_name");
            double qty = r.getDouble("input_qty");
            if (name == null || name.trim().isEmpty() || qty <= 0) continue;

            String unit = r.getString("input_unit");
            double grams = "kg".equals(unit) ? qty * 1000.0 : qty;
            manualRows.add(new Object[]{ name.trim(), grams });
        }
        r.close();
        ps.close();

        for (Object[] row : manualRows) {
            String name = (String) row[0];
            double grams = ((Double) row[1]).doubleValue();

            // 보유 Lot 목록
            List<Integer> lotIds = new ArrayList<Integer>();
            PreparedStatement psLots = conn.prepareStatement(
                    "SELECT lot_id FROM item_lots WHERE TRIM(item_name) = ? ORDER BY lot_id");
            psLots.setString(1, name);
            ResultSet rl = psLots.executeQuery();
            while (rl.next()) lotIds.add(rl.getInt("lot_id"));
            rl.close();
            psLots.close();

            if (!lotIds.isEmpty()) {
                double share = grams / lotIds.size();
                PreparedStatement psUpd = conn.prepareStatement(
                        "UPDATE item_lots SET "
                      + "  stock_qty_t = stock_qty_t - ?, stock_qty_kg = stock_qty_kg - ?, "
                      + "  stock_qty_g = stock_qty_g - ?, stock_qty_mg = stock_qty_mg - ?, "
                      + "  updated_at = CURRENT_TIMESTAMP WHERE lot_id = ?");
                for (Integer lotId : lotIds) {
                    psUpd.setDouble(1, share / 1000000.0);
                    psUpd.setDouble(2, share / 1000.0);
                    psUpd.setDouble(3, share);
                    psUpd.setDouble(4, share * 1000.0);
                    psUpd.setInt(5, lotId.intValue());
                    psUpd.addBatch();
                }
                psUpd.executeBatch();
                psUpd.close();
            }
            // 보유 Lot이 없으면 Lot 차감은 건너뛰고 총재고(items)만 차감 → 마이너스

            addToItemTotal(itemTotalMap, name, grams / 1000000.0, grams / 1000.0, grams, grams * 1000.0);
        }
    }
%>
