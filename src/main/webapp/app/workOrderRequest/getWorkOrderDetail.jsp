<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String orderIdStr = request.getParameter("order_id");
    int orderId = 0;
    try {
        if (orderIdStr != null) orderId = Integer.parseInt(orderIdStr);
    } catch (NumberFormatException e) {
        orderId = 0;
    }

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    response.setContentType("application/json; charset=UTF-8");
    StringBuilder json = new StringBuilder();

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        json.append("{");

        // 1. 마스터 정보 조회 (work_orders)
        String masterSql = "SELECT * FROM work_orders WHERE order_id = ?";
        pstmt = conn.prepareStatement(masterSql);
        pstmt.setInt(1, orderId);
        rs = pstmt.executeQuery();

        json.append("\"master\":{");
        if (rs.next()) {
            json.append("\"order_id\":").append(rs.getInt("order_id")).append(",");
            json.append("\"product_name\":\"").append(esc(rs.getString("product_name"))).append("\",");
            json.append("\"target_qty\":").append(rs.getDouble("target_qty")).append(",");
            json.append("\"target_unit\":\"").append(esc(rs.getString("target_unit"))).append("\",");
            json.append("\"manager_name\":\"").append(esc(rs.getString("manager_name"))).append("\",");
            json.append("\"machine\":\"").append(esc(rs.getString("machine"))).append("\",");
            json.append("\"appearance\":\"").append(esc(rs.getString("appearance"))).append("\",");
            json.append("\"scent\":\"").append(esc(rs.getString("scent"))).append("\",");
            json.append("\"specific_gravity\":\"").append(esc(rs.getString("specific_gravity"))).append("\",");
            json.append("\"ph\":\"").append(esc(rs.getString("ph"))).append("\",");
            json.append("\"theor_qty\":").append(rs.getDouble("theor_qty")).append(",");
            json.append("\"theor_unit\":\"").append(esc(rs.getString("theor_unit"))).append("\",");
            json.append("\"yield_rate\":").append(rs.getDouble("yield_rate")).append(",");
            json.append("\"yield_standard\":\"").append(esc(rs.getString("yield_standard"))).append("\"");
        }
        json.append("},");
        rs.close();
        pstmt.close();

        // 2. 하위 원료 목록 조회 (work_order_items)
        String itemSql = "SELECT * FROM work_order_items WHERE order_id = ? ORDER BY item_row_id ASC";
        pstmt = conn.prepareStatement(itemSql);
        pstmt.setInt(1, orderId);
        rs = pstmt.executeQuery();

        json.append("\"items\":[");
        boolean firstItem = true;
        while (rs.next()) {
            if (!firstItem) json.append(",");
            json.append("{")
                 .append("\"item_row_id\":").append(rs.getInt("item_row_id")).append(",")
                 .append("\"raw_material_name\":\"").append(esc(rs.getString("raw_material_name"))).append("\",")
                 .append("\"test_number\":\"").append(esc(rs.getString("test_number"))).append("\",")
                 .append("\"content_pct\":").append(rs.getDouble("content_pct")).append(",")
                 .append("\"order_qty_kg\":").append(rs.getDouble("order_qty_kg")).append(",")
                 .append("\"order_qty_g\":").append(rs.getDouble("order_qty_g")).append(",")
                 .append("\"unit_price\":").append(rs.getDouble("unit_price"))
                 .append("}");
            firstItem = false;
        }
        json.append("],");
        rs.close();
        pstmt.close();

        // 3. 제조방법 및 상 목록 조회 (work_order_phases)
        String phaseSql = "SELECT * FROM work_order_phases WHERE order_id = ? ORDER BY phase_row_id ASC";
        pstmt = conn.prepareStatement(phaseSql);
        pstmt.setInt(1, orderId);
        rs = pstmt.executeQuery();

        json.append("\"phases\":[");
        boolean firstPhase = true;
        while (rs.next()) {
            if (!firstPhase) json.append(",");
            json.append("{")
                 .append("\"phase_row_id\":").append(rs.getInt("phase_row_id")).append(",")
                 .append("\"phase_name\":\"").append(esc(rs.getString("phase_name"))).append("\",")
                 .append("\"phase_select_start\":\"").append(esc(rs.getString("phase_select_start") != null ? rs.getString("phase_select_start") : "1")).append("\",")
                 .append("\"phase_select_end\":\"").append(esc(rs.getString("phase_select_end") != null ? rs.getString("phase_select_end") : "1")).append("\",")
                 .append("\"method_desc\":\"").append(esc(rs.getString("method_desc"))).append("\",")
                 .append("\"note_desc\":\"").append(esc(rs.getString("note_desc"))).append("\"")
                 .append("}");
            firstPhase = false;
        }
        json.append("]");

        json.append("}");
        out.print(json.toString());

    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"error\": \"" + esc(e.getMessage()) + "\"}");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>
<%!
    // JSON 문자열 값에 들어갈 수 있는 특수문자를 전부 안전하게 이스케이프
    private String esc(String val) {
        if (val == null) return "";
        return val.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\r", "")
                  .replace("\n", "\\n")
                  .replace("\t", "\\t");
    }
%>
