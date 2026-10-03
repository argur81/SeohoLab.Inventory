<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    // 포장 지시 및 기록서(step5-Filling에서 저장한 데이터) 조회
    // 위치: /app/workOrderProgress/common/getWorkOrderFillingData.jsp
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
        out.print("{\"success\":false,\"message\":\"요청 ID가 누락되었습니다.\"}");
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

        json.append("{\"success\":true,");

        // 1. 요청/제조 기본정보 (제품명, 용량, 제조번호, EXP, 지시일자)
        String baseSql = "SELECT r.product_name, r.target_qty, r.target_unit, r.request_date, "
                + "m.batch_no, m.due_date, m.mfg_date, m.actual_qty, m.product_capacity, m.capacity_unit "
                + "FROM work_order_requests r LEFT JOIN work_order_making m ON r.request_id = m.request_id "
                + "WHERE r.request_id = ?";
        pstmt = conn.prepareStatement(baseSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();

        json.append("\"base\":{");
        if (rs.next()) {
            json.append("\"product_name\":\"").append(esc(rs.getString("product_name"))).append("\",");
            json.append("\"target_qty\":").append(rs.getDouble("target_qty")).append(",");
            json.append("\"target_unit\":\"").append(esc(rs.getString("target_unit"))).append("\",");
            json.append("\"request_date\":\"").append(rs.getString("request_date") != null ? rs.getString("request_date") : "").append("\",");
            json.append("\"batch_no\":\"").append(esc(rs.getString("batch_no"))).append("\",");
            json.append("\"due_date\":\"").append(rs.getString("due_date") != null ? rs.getString("due_date") : "").append("\",");
            json.append("\"mfg_date\":\"").append(rs.getString("mfg_date") != null ? rs.getString("mfg_date") : "").append("\",");
            json.append("\"actual_qty\":").append(rs.getDouble("actual_qty")).append(",");
            json.append("\"product_capacity\":").append(rs.getObject("product_capacity") != null ? rs.getDouble("product_capacity") : 0).append(",");
            json.append("\"capacity_unit\":\"").append(esc(rs.getString("capacity_unit"))).append("\"");
        }
        json.append("},");
        rs.close();
        pstmt.close();

        // 2. work_order_filling_report (헤더)
        String reportSql = "SELECT * FROM work_order_filling_report WHERE request_id = ?";
        pstmt = conn.prepareStatement(reportSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            json.append("\"report\":{");
            json.append("\"work_date\":\"").append(rs.getString("work_date") != null ? rs.getString("work_date") : "").append("\",");
            json.append("\"order_qty_ea\":").append(rs.getInt("order_qty_ea")).append(",");
            json.append("\"mfg_input_qty\":").append(rs.getDouble("mfg_input_qty")).append(",");
            json.append("\"item1_result\":\"").append(esc(rs.getString("item1_result"))).append("\",");
            json.append("\"item1_reason\":\"").append(esc(rs.getString("item1_reason"))).append("\",");
            json.append("\"item1_remark\":\"").append(esc(rs.getString("item1_remark"))).append("\",");
            json.append("\"item2_result\":\"").append(esc(rs.getString("item2_result"))).append("\",");
            json.append("\"item2_reason\":\"").append(esc(rs.getString("item2_reason"))).append("\",");
            json.append("\"item2_remark\":\"").append(esc(rs.getString("item2_remark"))).append("\",");
            json.append("\"item3_result\":\"").append(esc(rs.getString("item3_result"))).append("\",");
            json.append("\"item3_reason\":\"").append(esc(rs.getString("item3_reason"))).append("\",");
            json.append("\"item3_remark\":\"").append(esc(rs.getString("item3_remark"))).append("\",");
            json.append("\"item4_result\":\"").append(esc(rs.getString("item4_result"))).append("\",");
            json.append("\"item4_reason\":\"").append(esc(rs.getString("item4_reason"))).append("\",");
            json.append("\"item4_remark\":\"").append(esc(rs.getString("item4_remark"))).append("\",");
            json.append("\"work_hours\":").append(rs.getDouble("work_hours")).append(",");
            json.append("\"work_person_count\":").append(rs.getInt("work_person_count")).append(",");
            json.append("\"mfg_qty_kg\":").append(rs.getDouble("mfg_qty_kg")).append(",");
            json.append("\"produced_qty_kg\":").append(rs.getDouble("produced_qty_kg")).append(",");
            json.append("\"status_order_qty_ea\":").append(rs.getInt("status_order_qty_ea")).append(",");
            json.append("\"production_qty\":").append(rs.getInt("production_qty")).append(",");
            json.append("\"waste_qty\":").append(rs.getInt("waste_qty")).append(",");
            json.append("\"release_qty\":").append(rs.getInt("release_qty")).append(",");
            json.append("\"yield_rate\":").append(rs.getDouble("yield_rate")).append(",");
            json.append("\"defect_rate\":").append(rs.getDouble("defect_rate")).append(",");
            json.append("\"writer_name\":\"").append(esc(rs.getString("writer_name"))).append("\",");
            json.append("\"verdict\":\"").append(esc(rs.getString("verdict"))).append("\"");
            json.append("},");
        } else {
            json.append("\"report\":null,");
        }
        rs.close();
        pstmt.close();

        // 3. work_order_filling_items (포장재 투입 행)
        String itemsSql = "SELECT * FROM work_order_filling_items WHERE request_id = ? ORDER BY row_no ASC";
        pstmt = conn.prepareStatement(itemsSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();

        json.append("\"items\":[");
        boolean first = true;
        while (rs.next()) {
            if (!first) json.append(",");
            json.append("{");
            json.append("\"row_no\":").append(rs.getInt("row_no")).append(",");
            json.append("\"work_content\":\"").append(esc(rs.getString("work_content"))).append("\",");
            json.append("\"machine_name\":\"").append(esc(rs.getString("machine_name"))).append("\",");
            json.append("\"item_name\":\"").append(esc(rs.getString("item_name"))).append("\",");
            json.append("\"subsidiary_type\":\"").append(esc(rs.getString("subsidiary_type"))).append("\",");
            json.append("\"out_qty\":").append(rs.getInt("out_qty")).append(",");
            json.append("\"worker_name\":\"").append(esc(rs.getString("worker_name"))).append("\",");
            json.append("\"defect_qty\":").append(rs.getInt("defect_qty"));
            json.append("}");
            first = false;
        }
        json.append("]");

        json.append("}");
        out.print(json.toString());

    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"success\":false,\"message\":\"" + esc(e.getMessage()) + "\"}");
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
