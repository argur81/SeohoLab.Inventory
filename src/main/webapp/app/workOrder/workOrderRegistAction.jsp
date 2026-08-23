<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    // 한글 인코딩 설정
    request.setCharacterEncoding("UTF-8");

    // 파라미터 수신 (마스터 정보)
    String orderIdStr = request.getParameter("order_id");
    int orderId = 0;
    if (orderIdStr != null && !orderIdStr.trim().isEmpty()) {
        try {
            orderId = Integer.parseInt(orderIdStr);
        } catch (NumberFormatException e) {
            orderId = 0;
        }
    }

    String productName = request.getParameter("product_name");
    String targetQtyStr = request.getParameter("target_qty");
    String targetUnit = request.getParameter("target_unit");
    String managerName = request.getParameter("manager_name");
    String machine = request.getParameter("machine");
    String appearance = request.getParameter("appearance");
    String scent = request.getParameter("scent");
    String specificGravityStr = request.getParameter("specific_gravity");
    String phStr = request.getParameter("ph");
    String theorQtyStr = request.getParameter("theor_qty");
    String theorUnit = request.getParameter("theor_unit");
    String yieldRateStr = request.getParameter("yield_rate");
    String yieldStandard = request.getParameter("yield_standard");

    // 배열 형태의 하단 원료 투입 목록 파라미터 수신
    String[] rawMaterialNames = request.getParameterValues("raw_material_name");
    String[] testNumbers = request.getParameterValues("test_number");
    String[] contentPcts = request.getParameterValues("content_pct");
    String[] orderQtyKgs = request.getParameterValues("order_qty_kg");
    String[] orderQtyGs = request.getParameterValues("order_qty_g");
    String[] unitPrices = request.getParameterValues("unit_price");

    // 배열 형태의 제조방법 및 상(Phase) 관리 파라미터 수신
    String[] phaseTitles = request.getParameterValues("phase_title");
    String[] phaseStarts = request.getParameterValues("phase_start");
    String[] phaseEnds = request.getParameterValues("phase_end");
    String[] methodDescs = request.getParameterValues("method_desc");
    String[] noteDescs = request.getParameterValues("note_desc");

    // DB 연결 정보 설정 (MariaDB)
    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    boolean isSuccess = false;
    String errorMessage = "";

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        
        // 트랜잭션 시작
        conn.setAutoCommit(false);

        double targetQty = (targetQtyStr != null && !targetQtyStr.trim().isEmpty()) ? Double.parseDouble(targetQtyStr.replace(",", "")) : 0.0;
        double specificGravity = (specificGravityStr != null && !specificGravityStr.trim().isEmpty()) ? Double.parseDouble(specificGravityStr.replace(",", "")) : 0.0;
        double ph = (phStr != null && !phStr.trim().isEmpty()) ? Double.parseDouble(phStr.replace(",", "")) : 0.0;
        double theorQty = (theorQtyStr != null && !theorQtyStr.trim().isEmpty()) ? Double.parseDouble(theorQtyStr.replace(",", "")) : 0.0;
        double yieldRate = (yieldRateStr != null && !yieldRateStr.trim().isEmpty()) ? Double.parseDouble(yieldRateStr.replace(",", "")) : 0.0;

        if (orderId == 0) {
            String masterSql = "INSERT INTO work_orders (product_name, target_qty, target_unit, manager_name, machine, appearance, scent, specific_gravity, ph, theor_qty, theor_unit, yield_rate, yield_standard, status, reg_date) " +
                               "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'NORMAL', NOW())";
            
            pstmt = conn.prepareStatement(masterSql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, productName);
            pstmt.setDouble(2, targetQty);
            pstmt.setString(3, targetUnit);
            pstmt.setString(4, managerName);
            pstmt.setString(5, machine);
            pstmt.setString(6, appearance);
            pstmt.setString(7, scent);
            pstmt.setDouble(8, specificGravity);
            pstmt.setDouble(9, ph);
            pstmt.setDouble(10, theorQty);
            pstmt.setString(11, theorUnit);
            pstmt.setDouble(12, yieldRate);
            pstmt.setString(13, yieldStandard);
            
            pstmt.executeUpdate();

            rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                orderId = rs.getInt(1);
            }
            rs.close();
            pstmt.close();
        } else {
            String masterSql = "UPDATE work_orders SET product_name=?, target_qty=?, target_unit=?, manager_name=?, machine=?, appearance=?, scent=?, specific_gravity=?, ph=?, theor_qty=?, theor_unit=?, yield_rate=?, yield_standard=? WHERE order_id=?";
            
            pstmt = conn.prepareStatement(masterSql);
            pstmt.setString(1, productName);
            pstmt.setDouble(2, targetQty);
            pstmt.setString(3, targetUnit);
            pstmt.setString(4, managerName);
            pstmt.setString(5, machine);
            pstmt.setString(6, appearance);
            pstmt.setString(7, scent);
            pstmt.setDouble(8, specificGravity);
            pstmt.setDouble(9, ph);
            pstmt.setDouble(10, theorQty);
            pstmt.setString(11, theorUnit);
            pstmt.setDouble(12, yieldRate);
            pstmt.setString(13, yieldStandard);
            pstmt.setInt(14, orderId);
            
            pstmt.executeUpdate();
            pstmt.close();

            // 기존 아이템 및 페이즈 삭제 후 재등록
            pstmt = conn.prepareStatement("DELETE FROM work_order_items WHERE order_id = ?");
            pstmt.setInt(1, orderId);
            pstmt.executeUpdate();
            pstmt.close();

            pstmt = conn.prepareStatement("DELETE FROM work_order_phases WHERE order_id = ?");
            pstmt.setInt(1, orderId);
            pstmt.executeUpdate();
            pstmt.close();
        }

        // 원료 투입 목록 저장
        if (rawMaterialNames != null) {
            String itemSql = "INSERT INTO work_order_items (order_id, item_row_id, raw_material_name, test_number, content_pct, order_qty_kg, order_qty_g, unit_price) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(itemSql);

            for (int i = 0; i < rawMaterialNames.length; i++) {
                if (rawMaterialNames[i] == null || rawMaterialNames[i].trim().isEmpty()) continue;

                double contentPct = (contentPcts != null && i < contentPcts.length && contentPcts[i] != null && !contentPcts[i].trim().isEmpty()) ? Double.parseDouble(contentPcts[i].replace(",", "")) : 0.0;
                double orderKg = (orderQtyKgs != null && i < orderQtyKgs.length && orderQtyKgs[i] != null && !orderQtyKgs[i].trim().isEmpty()) ? Double.parseDouble(orderQtyKgs[i].replace(",", "")) : 0.0;
                double orderG = (orderQtyGs != null && i < orderQtyGs.length && orderQtyGs[i] != null && !orderQtyGs[i].trim().isEmpty()) ? Double.parseDouble(orderQtyGs[i].replace(",", "")) : 0.0;
                double unitPrice = (unitPrices != null && i < unitPrices.length && unitPrices[i] != null && !unitPrices[i].trim().isEmpty()) ? Double.parseDouble(unitPrices[i].replace(",", "")) : 0.0;

                pstmt.setInt(1, orderId);
                pstmt.setInt(2, i + 1);
                pstmt.setString(3, rawMaterialNames[i]);
                pstmt.setString(4, (testNumbers != null && i < testNumbers.length) ? testNumbers[i] : "");
                pstmt.setDouble(5, contentPct);
                pstmt.setDouble(6, orderKg);
                pstmt.setDouble(7, orderG);
                pstmt.setDouble(8, unitPrice);
                
                pstmt.addBatch();
            }
            pstmt.executeBatch();
            pstmt.close();
        }

        // 상(Phase) 관리 정보 저장
        if (phaseTitles != null) {
            String phaseSql = "INSERT INTO work_order_phases (order_id, phase_row_id, phase_name, phase_start, phase_end, method_desc, note_desc) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(phaseSql);

            for (int i = 0; i < phaseTitles.length; i++) {
                int pStart = (phaseStarts != null && i < phaseStarts.length && phaseStarts[i] != null && !phaseStarts[i].trim().isEmpty()) ? Integer.parseInt(phaseStarts[i]) : 1;
                int pEnd = (phaseEnds != null && i < phaseEnds.length && phaseEnds[i] != null && !phaseEnds[i].trim().isEmpty()) ? Integer.parseInt(phaseEnds[i]) : 1;

                pstmt.setInt(1, orderId);
                pstmt.setInt(2, i + 1);
                pstmt.setString(3, phaseTitles[i]);
                pstmt.setInt(4, pStart);
                pstmt.setInt(5, pEnd);
                pstmt.setString(6, (methodDescs != null && i < methodDescs.length) ? methodDescs[i] : "");
                pstmt.setString(7, (noteDescs != null && i < noteDescs.length) ? noteDescs[i] : "");

                pstmt.addBatch();
            }
            pstmt.executeBatch();
            pstmt.close();
        }

        conn.commit();
        isSuccess = true;

    } catch (Exception e) {
        e.printStackTrace();
        errorMessage = e.getMessage();
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
<script>
    <% if (isSuccess) { %>
        alert("정상적으로 처리되었습니다.");
        location.href = "workOrderList.jsp";
    <% } else { %>
        alert("처리 중 오류가 발생했습니다.\n오류 내용: <%= errorMessage != null ? errorMessage.replace("\"", "\\\"").replace("\n", " ") : "알 수 없는 오류" %>");
        history.back();
    <% } %>
</script>