<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
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
        out.print("{\"making\":null,\"items\":[]}");
        return;
    }

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    StringBuilder json = new StringBuilder();

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        json.append("{");

        // 1. 제조 헤더 정보
        String makingSql = "SELECT batch_no, due_date, maker_name, mfg_date, appearance_result, scent_result, "
                          + "specific_gravity_result, ph_result, actual_qty, yield_rate_actual "
                          + "FROM work_order_making WHERE request_id = ?";
        pstmt = conn.prepareStatement(makingSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            json.append("\"making\":{");
            json.append("\"batch_no\":\"").append(esc(rs.getString("batch_no"))).append("\",");
            json.append("\"due_date\":\"").append(rs.getString("due_date") != null ? rs.getString("due_date") : "").append("\",");
            json.append("\"maker_name\":\"").append(esc(rs.getString("maker_name"))).append("\",");
            json.append("\"mfg_date\":\"").append(rs.getString("mfg_date") != null ? rs.getString("mfg_date") : "").append("\",");
            json.append("\"appearance_result\":\"").append(esc(rs.getString("appearance_result"))).append("\",");
            json.append("\"scent_result\":\"").append(esc(rs.getString("scent_result"))).append("\",");
            json.append("\"specific_gravity_result\":\"").append(esc(rs.getString("specific_gravity_result"))).append("\",");
            json.append("\"ph_result\":\"").append(esc(rs.getString("ph_result"))).append("\",");
            json.append("\"actual_qty\":").append(rs.getDouble("actual_qty")).append(",");
            json.append("\"yield_rate_actual\":").append(rs.getDouble("yield_rate_actual"));
            json.append("},");
        } else {
            json.append("\"making\":null,");
        }
        rs.close();
        pstmt.close();

        // 2. 행별 요약 (item_row_id -> raw_material_name/is_extra/lot_numbers/input_qty/input_unit/note)
        String itemsSql = "SELECT item_row_id, raw_material_name, is_extra, lot_numbers, input_qty, input_unit, note "
                         + "FROM work_order_making_items WHERE request_id = ? ORDER BY item_row_id ASC";
        pstmt = conn.prepareStatement(itemsSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();

        java.util.Map<Integer, StringBuilder> itemMap = new java.util.LinkedHashMap<Integer, StringBuilder>();
        while (rs.next()) {
            int rowId = rs.getInt("item_row_id");
            StringBuilder itemJson = new StringBuilder();
            itemJson.append("{");
            itemJson.append("\"item_row_id\":").append(rowId).append(",");
            itemJson.append("\"raw_material_name\":\"").append(esc(rs.getString("raw_material_name"))).append("\",");
            itemJson.append("\"is_extra\":").append(rs.getInt("is_extra")).append(",");
            itemJson.append("\"lot_numbers\":\"").append(esc(rs.getString("lot_numbers"))).append("\",");
            itemJson.append("\"input_qty\":").append(rs.getDouble("input_qty")).append(",");
            itemJson.append("\"input_unit\":\"").append(esc(rs.getString("input_unit"))).append("\",");
            itemJson.append("\"note\":\"").append(esc(rs.getString("note"))).append("\",");
            itemJson.append("\"lots\":[");
            itemMap.put(rowId, itemJson);
        }
        rs.close();
        pstmt.close();

        // 3. 행 × Lot별 상세 사용량을 각 item에 매달기
        String lotSql = "SELECT item_row_id, lot_number, qty_t, qty_kg, qty_g, qty_mg FROM work_order_making_lot_usage WHERE request_id = ? ORDER BY item_row_id ASC, lot_number ASC";
        pstmt = conn.prepareStatement(lotSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();

        java.util.Map<Integer, Boolean> firstLotFlag = new java.util.HashMap<Integer, Boolean>();
        while (rs.next()) {
            int rowId = rs.getInt("item_row_id");
            StringBuilder itemJson = itemMap.get(rowId);
            if (itemJson == null) continue;

            boolean isFirst = !firstLotFlag.containsKey(rowId);
            if (!isFirst) itemJson.append(",");
            firstLotFlag.put(rowId, true);

            itemJson.append("{");
            itemJson.append("\"lot_number\":\"").append(esc(rs.getString("lot_number"))).append("\",");
            itemJson.append("\"t\":").append(rs.getDouble("qty_t")).append(",");
            itemJson.append("\"kg\":").append(rs.getDouble("qty_kg")).append(",");
            itemJson.append("\"g\":").append(rs.getDouble("qty_g")).append(",");
            itemJson.append("\"mg\":").append(rs.getDouble("qty_mg"));
            itemJson.append("}");
        }
        rs.close();
        pstmt.close();

        json.append("\"items\":[");
        boolean firstItem = true;
        for (StringBuilder itemJson : itemMap.values()) {
            if (!firstItem) json.append(",");
            json.append(itemJson).append("]}"); // lots 배열 닫고 item 객체 닫기
            firstItem = false;
        }
        json.append("]");

        json.append("}");
        out.print(json.toString());

    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"making\":null,\"items\":[],\"error\":\"" + esc(e.getMessage()) + "\"}");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>
<%!
    private String esc(String val) {
        if (val == null) return "";
        return val.replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "").replace("\n", "\\n");
    }
%>