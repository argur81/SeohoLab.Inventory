<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

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

    StringBuilder json = new StringBuilder();

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        // 1. work_order_requests 조회
        String reqSql = "SELECT request_id, order_id, product_name, target_qty, target_unit, progress_status, requested_by, request_date FROM work_order_requests WHERE request_id = ?";
        pstmt = conn.prepareStatement(reqSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();

        if (!rs.next()) {
            out.print("{\"success\":false,\"message\":\"해당 제조요청 정보를 찾을 수 없습니다.\"}");
            return;
        }

        int orderId = rs.getInt("order_id");
        json.append("{");
        json.append("\"request\":{");
        json.append("\"request_id\":").append(rs.getInt("request_id")).append(",");
        json.append("\"order_id\":").append(orderId).append(",");
        json.append("\"product_name\":\"").append(escapeJson(rs.getString("product_name"))).append("\",");
        json.append("\"target_qty\":").append(rs.getDouble("target_qty")).append(",");
        json.append("\"target_unit\":\"").append(escapeJson(rs.getString("target_unit"))).append("\",");
        json.append("\"progress_status\":\"").append(escapeJson(rs.getString("progress_status"))).append("\",");
        json.append("\"requested_by\":\"").append(escapeJson(rs.getString("requested_by"))).append("\",");
        json.append("\"request_date\":\"").append(rs.getString("request_date") != null ? rs.getString("request_date") : "").append("\"");
        json.append("},");
        rs.close();
        pstmt.close();

        // 2. work_orders (마스터) 조회
        String masterSql = "SELECT machine, appearance, scent, specific_gravity, ph, theor_qty, theor_unit, yield_rate, yield_standard FROM work_orders WHERE order_id = ?";
        pstmt = conn.prepareStatement(masterSql);
        pstmt.setInt(1, orderId);
        rs = pstmt.executeQuery();

        json.append("\"master\":{");
        if (rs.next()) {
            json.append("\"machine\":\"").append(escapeJson(rs.getString("machine"))).append("\",");
            json.append("\"appearance\":\"").append(escapeJson(rs.getString("appearance"))).append("\",");
            json.append("\"scent\":\"").append(escapeJson(rs.getString("scent"))).append("\",");
            json.append("\"specific_gravity\":\"").append(escapeJson(rs.getString("specific_gravity"))).append("\",");
            json.append("\"ph\":\"").append(escapeJson(rs.getString("ph"))).append("\",");
            json.append("\"theor_qty\":").append(rs.getDouble("theor_qty")).append(",");
            json.append("\"theor_unit\":\"").append(escapeJson(rs.getString("theor_unit"))).append("\",");
            json.append("\"yield_rate\":").append(rs.getDouble("yield_rate")).append(",");
            json.append("\"yield_standard\":\"").append(escapeJson(rs.getString("yield_standard"))).append("\"");
        }
        json.append("},");
        rs.close();
        pstmt.close();

        // 3. work_order_items (원료 목록) 조회
        String itemSql = "SELECT raw_material_name, test_number, content_pct, order_qty_kg, order_qty_g FROM work_order_items WHERE order_id = ? ORDER BY item_row_id ASC";
        pstmt = conn.prepareStatement(itemSql);
        pstmt.setInt(1, orderId);
        rs = pstmt.executeQuery();

        json.append("\"items\":[");
        boolean firstItem = true;
        while (rs.next()) {
            if (!firstItem) json.append(",");
            json.append("{");
            json.append("\"raw_material_name\":\"").append(escapeJson(rs.getString("raw_material_name"))).append("\",");
            json.append("\"test_number\":\"").append(escapeJson(rs.getString("test_number"))).append("\",");
            json.append("\"content_pct\":").append(rs.getDouble("content_pct")).append(",");
            json.append("\"order_qty_kg\":").append(rs.getDouble("order_qty_kg")).append(",");
            json.append("\"order_qty_g\":").append(rs.getDouble("order_qty_g"));
            json.append("}");
            firstItem = false;
        }
        json.append("],");
        rs.close();
        pstmt.close();

        // 4. work_order_phases (페이즈/제조방법) 조회
        String phaseSql = "SELECT phase_name, phase_select_start, phase_select_end, method_desc, note_desc FROM work_order_phases WHERE order_id = ? ORDER BY phase_row_id ASC";
        pstmt = conn.prepareStatement(phaseSql);
        pstmt.setInt(1, orderId);
        rs = pstmt.executeQuery();

        json.append("\"phases\":[");
        boolean firstPhase = true;
        while (rs.next()) {
            if (!firstPhase) json.append(",");
            json.append("{");
            json.append("\"phase_name\":\"").append(escapeJson(rs.getString("phase_name"))).append("\",");
            json.append("\"phase_select_start\":\"").append(escapeJson(rs.getString("phase_select_start"))).append("\",");
            json.append("\"phase_select_end\":\"").append(escapeJson(rs.getString("phase_select_end"))).append("\",");
            json.append("\"method_desc\":\"").append(escapeJson(rs.getString("method_desc"))).append("\",");
            json.append("\"note_desc\":\"").append(escapeJson(rs.getString("note_desc"))).append("\"");
            json.append("}");
            firstPhase = false;
        }
        json.append("]");

        json.append("}");
        out.print(json.toString());

    } catch (Exception e) {
        e.printStackTrace();
        // 에러 발생 시 JSON 형태로 에러 메시지 반환
        String errMsg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Unknown Error";
        out.print("{\"success\":false,\"message\":\"서버 에러 발생: " + escapeJson(errMsg) + "\"}");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>
<%!
    private String escapeJson(String val) {
        if (val == null) return "";
        return val.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\r", "")
                  .replace("\n", "\\n");
    }
%>