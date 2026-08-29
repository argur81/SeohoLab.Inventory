<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. order_id 파라미터 수신 (신규일 경우 null이거나 빈값이거나 "0"임)
    String orderIdStr = request.getParameter("order_id");
    int orderId = 0;
    if (orderIdStr != null && !orderIdStr.trim().isEmpty()) {
        try {
            orderId = Integer.parseInt(orderIdStr);
        } catch (NumberFormatException e) {
            orderId = 0;
        }
    }

    // 2. 마스터 정보 파라미터 수신
    String productName = request.getParameter("product_name");
    String targetQtyStr = request.getParameter("target_qty");
    String targetUnit = request.getParameter("target_unit");
    String managerName = request.getParameter("manager_name");
    String machine = request.getParameter("machine");
    String appearance = request.getParameter("appearance");
    String scent = request.getParameter("scent");
    String specificGravity = request.getParameter("specific_gravity");
    String ph = request.getParameter("ph");
    String theorQtyStr = request.getParameter("theor_qty");
    String theorUnit = request.getParameter("theor_unit");
    String yieldRateStr = request.getParameter("yield_rate");
    String yieldStandard = request.getParameter("yield_standard");

    double targetQty = (targetQtyStr != null && !targetQtyStr.isEmpty()) ? Double.parseDouble(targetQtyStr.replace(",", "")) : 0;
    double theorQty = (theorQtyStr != null && !theorQtyStr.isEmpty()) ? Double.parseDouble(theorQtyStr.replace(",", "")) : 0;
    double yieldRate = (yieldRateStr != null && !yieldRateStr.isEmpty()) ? Double.parseDouble(yieldRateStr.replace(",", "")) : 0;

    // 3. 하위 동적 행 파라미터들 수신 (배열 형태)
    String[] rawMaterialNames = request.getParameterValues("raw_material_name");
    String[] testNumbers = request.getParameterValues("test_number");
    String[] contentPcts = request.getParameterValues("content_pct");
    String[] orderQtyKgs = request.getParameterValues("order_qty_kg");
    String[] orderQtyGs = request.getParameterValues("order_qty_g");
    String[] unitPrices = request.getParameterValues("unit_price");

    String[] phaseTitles = request.getParameterValues("phase_title");
    String[] phaseStarts = request.getParameterValues("phase_start");
    String[] phaseEnds = request.getParameterValues("phase_end");
    String[] methodDescs = request.getParameterValues("method_desc");
    String[] noteDescs = request.getParameterValues("note_desc");

    // DB 접속 정보
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
        conn.setAutoCommit(false); // 트랜잭션 시작

        if (orderId == 0) {
            // [신규 등록인 경우] work_orders에 먼저 INSERT하여 새로운 order_id 생성
            String insertOrderSql = "INSERT INTO work_orders (product_name, target_qty, target_unit, manager_name, machine, appearance, scent, specific_gravity, ph, theor_qty, theor_unit, yield_rate, yield_standard, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'TEMP')";
            pstmt = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, productName != null ? productName : "");
            pstmt.setDouble(2, targetQty);
            pstmt.setString(3, targetUnit != null ? targetUnit : "kg");
            pstmt.setString(4, managerName != null ? managerName : "이소희");
            pstmt.setString(5, machine != null ? machine : "");
            pstmt.setString(6, appearance != null ? appearance : "");
            pstmt.setString(7, scent != null ? scent : "");
            pstmt.setString(8, specificGravity != null ? specificGravity : "");
            pstmt.setString(9, ph != null ? ph : "");
            pstmt.setDouble(10, theorQty);
            pstmt.setString(11, theorUnit != null ? theorUnit : "kg");
            pstmt.setDouble(12, yieldRate);
            pstmt.setString(13, yieldStandard != null ? yieldStandard : "");
            pstmt.executeUpdate();

            // 생성된 auto_increment order_id 가져오기
            rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                orderId = rs.getInt(1);
            }
            rs.close();
            pstmt.close();
        } else {
            // [기존 수정인 경우]
            // 4. 해당 order_id가 실제로 존재하는지 확인
            String checkSql = "SELECT COUNT(*) FROM work_orders WHERE order_id = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, orderId);
            rs = pstmt.executeQuery();
            if (rs.next() && rs.getInt(1) == 0) {
                throw new Exception("해당 작업지시서(ID: " + orderId + ")가 존재하지 않아 수정할 수 없습니다.");
            }
            rs.close();
            pstmt.close();

            // 5. work_orders 마스터 정보 업데이트
            String updateOrderSql = "UPDATE work_orders SET product_name = ?, target_qty = ?, target_unit = ?, manager_name = ?, machine = ?, appearance = ?, scent = ?, specific_gravity = ?, ph = ?, theor_qty = ?, theor_unit = ?, yield_rate = ?, yield_standard = ?, status = 'TEMP' WHERE order_id = ?";
            pstmt = conn.prepareStatement(updateOrderSql);
            pstmt.setString(1, productName);
            pstmt.setDouble(2, targetQty);
            pstmt.setString(3, targetUnit);
            pstmt.setString(4, managerName);
            pstmt.setString(5, machine);
            pstmt.setString(6, appearance);
            pstmt.setString(7, scent);
            pstmt.setString(8, specificGravity != null ? specificGravity : "");
            pstmt.setString(9, ph != null ? ph : "");
            pstmt.setDouble(10, theorQty);
            pstmt.setString(11, theorUnit);
            pstmt.setDouble(12, yieldRate);
            pstmt.setString(13, yieldStandard);
            pstmt.setInt(14, orderId);
            pstmt.executeUpdate();
            pstmt.close();

            // 6. 기존 하위 데이터 삭제 (수정 시에만 기존 하위 항목 갈아끼우기 위해 삭제)
            String delItemsSql = "DELETE FROM work_order_items WHERE order_id = ?";
            pstmt = conn.prepareStatement(delItemsSql);
            pstmt.setInt(1, orderId);
            pstmt.executeUpdate();
            pstmt.close();

            String delPhasesSql = "DELETE FROM work_order_phases WHERE order_id = ?";
            pstmt = conn.prepareStatement(delPhasesSql);
            pstmt.setInt(1, orderId);
            pstmt.executeUpdate();
            pstmt.close();
        }

        // 7. work_order_items 새로 등록 (신규/수정 공통)
        if (rawMaterialNames != null && rawMaterialNames.length > 0) {
            String insertItemSql = "INSERT INTO work_order_items (order_id, item_row_id, row_index, raw_material_name, test_number, content_pct, order_qty_kg, order_qty_g, unit_price) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(insertItemSql);

            int actualIdx = 1;
            for (int i = 0; i < rawMaterialNames.length; i++) {
                if (rawMaterialNames[i] == null || rawMaterialNames[i].trim().isEmpty()) continue;

                double cPct = (contentPcts != null && i < contentPcts.length && contentPcts[i] != null && !contentPcts[i].isEmpty()) ? Double.parseDouble(contentPcts[i].replace(",", "")) : 0;
                double oKg = (orderQtyKgs != null && i < orderQtyKgs.length && orderQtyKgs[i] != null && !orderQtyKgs[i].isEmpty()) ? Double.parseDouble(orderQtyKgs[i].replace(",", "")) : 0;
                double oG = (orderQtyGs != null && i < orderQtyGs.length && orderQtyGs[i] != null && !orderQtyGs[i].isEmpty()) ? Double.parseDouble(orderQtyGs[i].replace(",", "")) : 0;
                double uPrice = (unitPrices != null && i < unitPrices.length && unitPrices[i] != null && !unitPrices[i].isEmpty()) ? Double.parseDouble(unitPrices[i].replace(",", "")) : 0;

                pstmt.setInt(1, orderId);
                pstmt.setInt(2, actualIdx);   // item_row_id
                pstmt.setInt(3, actualIdx);   // row_index
                pstmt.setString(4, rawMaterialNames[i]);
                pstmt.setString(5, (testNumbers != null && i < testNumbers.length) ? testNumbers[i] : "");
                pstmt.setDouble(6, cPct);
                pstmt.setDouble(7, oKg);
                pstmt.setDouble(8, oG);
                pstmt.setDouble(9, uPrice);
                pstmt.addBatch();
                
                actualIdx++;
            }
            pstmt.executeBatch();
            pstmt.close();
        }

        // 8. work_order_phases 새로 등록 (신규/수정 공통)
        if (phaseTitles != null && phaseTitles.length > 0) {
            String insertPhaseSql = "INSERT INTO work_order_phases (order_id, phase_row_id, phase_name, phase_select_start, phase_select_end, method_desc, note_desc) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(insertPhaseSql);

            int actualPhaseIdx = 1;
            for (int i = 0; i < phaseTitles.length; i++) {
                int startNum = (phaseStarts != null && i < phaseStarts.length && phaseStarts[i] != null && !phaseStarts[i].isEmpty()) ? Integer.parseInt(phaseStarts[i]) : 1;
                int endNum = (phaseEnds != null && i < phaseEnds.length && phaseEnds[i] != null && !phaseEnds[i].isEmpty()) ? Integer.parseInt(phaseEnds[i]) : 1;

                pstmt.setInt(1, orderId);
                pstmt.setInt(2, actualPhaseIdx); // phase_row_id
                pstmt.setString(3, phaseTitles[i]);
                pstmt.setInt(4, startNum);
                pstmt.setInt(5, endNum);
                pstmt.setString(6, (methodDescs != null && i < methodDescs.length) ? methodDescs[i] : "");
                pstmt.setString(7, (noteDescs != null && i < noteDescs.length) ? noteDescs[i] : "");
                pstmt.addBatch();
                
                actualPhaseIdx++;
            }
            pstmt.executeBatch();
            pstmt.close();
        }

        conn.commit();
%>
        <script>
            alert('임시저장 되었습니다.');
            location.href = 'workOrderMgmtList.jsp';
        </script>
<%
    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
        }
        e.printStackTrace();
%>
        <script>
            alert('임시저장 중 오류가 발생했습니다: <%= e.getMessage().replaceAll("'", "\\\\'") %>');
            history.back();
        </script>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>