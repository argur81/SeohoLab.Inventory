<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // ============================================================
    // [제조완료] 버튼 처리
    // 1. work_order_making_lot_usage (실제 사용한 Lot/수량, 원료명 직접 보유 - 추가원료 포함)
    // 2. item_lots (원료 Lot별 재고) 차감
    // 3. items (원료 총재고) 차감 (Lot별 사용량 합계만큼)
    // 4. work_order_requests.progress_status 를 '제조완료'로 변경
    // ※ work_order_items JOIN 없이 처리 -> 지시서 원료든 제조중 추가원료든 동일하게 차감됨
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
        String lotUsageSql = "SELECT lot_number, qty_t, qty_kg, qty_g, qty_mg, raw_material_name "
                + "FROM work_order_making_lot_usage WHERE request_id = ?";
        pstmt = conn.prepareStatement(lotUsageSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();

        // 원료명별 총 차감량 누적 (items 테이블 갱신용)
        Map<String, double[]> itemTotalMap = new LinkedHashMap<String, double[]>(); // [t, kg, g, mg]

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
            String key = rawMaterialName.trim();
            double[] sums = itemTotalMap.get(key);
            if (sums == null) {
                sums = new double[]{0, 0, 0, 0};
                itemTotalMap.put(key, sums);
            }
            sums[0] += t; sums[1] += kg; sums[2] += g; sums[3] += mg;
        }
        rs.close();
        pstmt.close();

        if (usageCount > 0) {
            pstmtLot.executeBatch();
        }
        pstmtLot.close();

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