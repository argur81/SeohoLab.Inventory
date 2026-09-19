<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    // 같은 제품명으로 가장 최근에 제조완료(이후 단계 포함)된 요청의 원료 구성(원료명+함량%)을 반환
    // - workOrderProgressDetail.jsp에서 [제조시작] 클릭 시 현재 지시서와 비교하기 위해 사용
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    String productName = request.getParameter("product_name");
    String excludeRequestIdStr = request.getParameter("exclude_request_id");
    int excludeRequestId = 0;
    try {
        if (excludeRequestIdStr != null) excludeRequestId = Integer.parseInt(excludeRequestIdStr.trim());
    } catch (Exception e) {
        excludeRequestId = 0;
    }

    if (productName == null || productName.trim().isEmpty()) {
        out.print("{\"found\":false}");
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

        // 같은 제품명 + 자기 자신 제외 + 제조완료 이후 단계(제조완료/충진중/생산완료) 중 가장 최근 것
        String findSql = "SELECT r.request_id, r.order_id, m.batch_no, r.request_date "
                + "FROM work_order_requests r "
                + "LEFT JOIN work_order_making m ON r.request_id = m.request_id "
                + "WHERE r.product_name = ? AND r.request_id != ? "
                + "  AND r.progress_status IN ('제조완료', '충진중', '생산완료') "
                + "ORDER BY r.request_id DESC LIMIT 1";
        pstmt = conn.prepareStatement(findSql);
        pstmt.setString(1, productName.trim());
        pstmt.setInt(2, excludeRequestId);
        rs = pstmt.executeQuery();

        if (!rs.next()) {
            out.print("{\"found\":false}");
            return;
        }

        int prevRequestId = rs.getInt("request_id");
        int prevOrderId = rs.getInt("order_id");
        String prevBatchNo = rs.getString("batch_no");
        Timestamp prevDate = rs.getTimestamp("request_date");
        rs.close();
        pstmt.close();

        StringBuilder json = new StringBuilder();
        json.append("{\"found\":true,");
        json.append("\"previous_request_id\":").append(prevRequestId).append(",");
        json.append("\"previous_batch_no\":\"").append(esc(prevBatchNo)).append("\",");
        json.append("\"previous_date\":\"").append(prevDate != null ? prevDate.toString() : "").append("\",");
        json.append("\"items\":[");

        String itemSql = "SELECT raw_material_name, content_pct FROM work_order_items WHERE order_id = ? ORDER BY item_row_id ASC";
        pstmt = conn.prepareStatement(itemSql);
        pstmt.setInt(1, prevOrderId);
        rs = pstmt.executeQuery();

        boolean first = true;
        while (rs.next()) {
            if (!first) json.append(",");
            json.append("{");
            json.append("\"raw_material_name\":\"").append(esc(rs.getString("raw_material_name"))).append("\",");
            json.append("\"content_pct\":").append(rs.getDouble("content_pct"));
            json.append("}");
            first = false;
        }
        json.append("]}");

        out.print(json.toString());

    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"found\":false,\"error\":\"" + esc(e.getMessage()) + "\"}");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>
<%!
    private String esc(String val) {
        if (val == null) return "";
        return val.replace("\\", "\\\\").replace("\"", "\\\"");
    }
%>
