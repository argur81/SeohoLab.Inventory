<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. 수정할 마스터 지시서 ID 수신
    String orderIdStr = request.getParameter("order_id");
    if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
    int orderId = Integer.parseInt(orderIdStr);

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

    // DB 접속 정보 (MariaDB)
    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        conn.setAutoCommit(false); // 트랜잭션 시작

        // 4. work_orders 마스터 정보 업데이트
        String updateOrderSql = "UPDATE work_orders SET product_name = ?, target_qty = ?, target_unit = ?, manager_name = ?, machine = ?, appearance = ?, scent = ?, specific_gravity = ?, ph = ?, theor_qty = ?, theor_unit = ?, yield_rate = ?, yield_standard = ?, status = 'CONFIRM' WHERE order_id = ?";
        pstmt = conn.prepareStatement(updateOrderSql);
        pstmt.setString(1, productName);
        pstmt.setDouble(2, targetQty);
        pstmt.setString(3, targetUnit);
        pstmt.setString(4, managerName);
        pstmt.setString(5, machine);
        pstmt.setString(6, appearance);
        pstmt.setString(7, scent);
        pstmt.setString(8, specificGravity);
        pstmt.setString(9, ph);
        pstmt.setDouble(10, theorQty);
        pstmt.setString(11, theorUnit);
        pstmt.setDouble(12, yieldRate);
        pstmt.setString(13, yieldStandard);
        pstmt.setInt(14, orderId);
        pstmt.executeUpdate();
        pstmt.close();

        // 5. 기존 하위 데이터(items, phases) 삭제
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

        // 6. work_order_items (원료 투입 목록) 새로 등록 (유효한 행만 순번 재부여)
        if (rawMaterialNames != null && rawMaterialNames.length > 0) {
            String insertItemSql = "INSERT INTO work_order_items (order_id, item_row_id, raw_material_name, test_number, content_pct, order_qty_kg, order_qty_g, unit_price) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(insertItemSql);

            int validRowIdx = 1; // 순차적인 행 번호 부여용 변수
            for (int i = 0; i < rawMaterialNames.length; i++) {
                if (rawMaterialNames[i] == null || rawMaterialNames[i].trim().isEmpty()) continue;

                double cPct = (contentPcts != null && i < contentPcts.length && contentPcts[i] != null && !contentPcts[i].isEmpty()) ? Double.parseDouble(contentPcts[i].replace(",", "")) : 0;
                double oKg = (orderQtyKgs != null && i < orderQtyKgs.length && orderQtyKgs[i] != null && !orderQtyKgs[i].isEmpty()) ? Double.parseDouble(orderQtyKgs[i].replace(",", "")) : 0;
                double oG = (orderQtyGs != null && i < orderQtyGs.length && orderQtyGs[i] != null && !orderQtyGs[i].isEmpty()) ? Double.parseDouble(orderQtyGs[i].replace(",", "")) : 0;
                double uPrice = (unitPrices != null && i < unitPrices.length && unitPrices[i] != null && !unitPrices[i].isEmpty()) ? Double.parseDouble(unitPrices[i].replace(",", "")) : 0;

                pstmt.setInt(1, orderId);
                pstmt.setInt(2, validRowIdx++); // 1부터 순차적으로 증가
                pstmt.setString(3, rawMaterialNames[i]);
                pstmt.setString(4, (testNumbers != null && i < testNumbers.length) ? testNumbers[i] : "");
                pstmt.setDouble(5, cPct);
                pstmt.setDouble(6, oKg);
                pstmt.setDouble(7, oG);
                pstmt.setDouble(8, uPrice);
                pstmt.addBatch();
            }
            pstmt.executeBatch();
            pstmt.close();
        }

        // 7. work_order_phases (제조 방법 및 상 관리) 새로 등록
        if (phaseTitles != null && phaseTitles.length > 0) {
            String insertPhaseSql = "INSERT INTO work_order_phases (order_id, phase_row_id, phase_name, phase_select_start, phase_select_end, method_desc, note_desc) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(insertPhaseSql);

            for (int i = 0; i < phaseTitles.length; i++) {
                int startNum = (phaseStarts != null && i < phaseStarts.length && phaseStarts[i] != null && !phaseStarts[i].isEmpty()) ? Integer.parseInt(phaseStarts[i]) : 1;
                int endNum = (phaseEnds != null && i < phaseEnds.length && phaseEnds[i] != null && !phaseEnds[i].isEmpty()) ? Integer.parseInt(phaseEnds[i]) : 1;

                pstmt.setInt(1, orderId);
                pstmt.setInt(2, i + 1);
                pstmt.setString(3, phaseTitles[i]);
                pstmt.setInt(4, startNum);
                pstmt.setInt(5, endNum);
                pstmt.setString(6, (methodDescs != null && i < methodDescs.length) ? methodDescs[i] : "");
                pstmt.setString(7, (noteDescs != null && i < noteDescs.length) ? noteDescs[i] : "");
                pstmt.addBatch();
            }
            pstmt.executeBatch();
            pstmt.close();
        }

        conn.commit(); // 커밋
%>
        <script>
            alert('성공적으로 수정되었습니다.');
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
            alert('수정 중 오류가 발생했습니다: <%= e.getMessage().replaceAll("'", "\\\\'") %>');
            history.back();
        </script>
<%
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>