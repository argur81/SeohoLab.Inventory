<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%
    // ============================================================
    // 제조요청 등록 액션
    // 1. work_orders에서 지시서 정보 조회
    // 2. work_order_requests 테이블에 요청 이력 INSERT
    // 3. 구글챗(Google Chat) 웹훅으로 알림 전송
    // ============================================================
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    // 로그인 사용자 아이디 (세션)
    String loginUserId = (String) session.getAttribute("userId");
    if (loginUserId == null || loginUserId.trim().isEmpty()) {
        loginUserId = (String) session.getAttribute("loginId");
    }

    String orderIdStr = request.getParameter("order_id");
    boolean isSuccess = false;
    String message = "";

    if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
        message = "잘못된 접근입니다. (지시서 정보 누락)";
        out.print("{\"success\":false,\"message\":\"" + message + "\"}");
        return;
    }

    int orderId = 0;
    try {
        orderId = Integer.parseInt(orderIdStr.trim());
    } catch (NumberFormatException e) {
        out.print("{\"success\":false,\"message\":\"유효하지 않은 지시서 ID입니다.\"}");
        return;
    }

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String productName = "";
    double targetQty = 0;
    String targetUnit = "kg";

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        conn.setAutoCommit(false);

        // 1. 지시서 마스터 정보 조회
        String masterSql = "SELECT product_name, target_qty, target_unit FROM work_orders WHERE order_id = ?";
        pstmt = conn.prepareStatement(masterSql);
        pstmt.setInt(1, orderId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            productName = rs.getString("product_name") != null ? rs.getString("product_name") : "";
            targetQty = rs.getDouble("target_qty");
            targetUnit = rs.getString("target_unit") != null ? rs.getString("target_unit") : "kg";
        } else {
            conn.rollback();
            out.print("{\"success\":false,\"message\":\"해당 제조 지시서를 찾을 수 없습니다.\"}");
            return;
        }
        rs.close();
        pstmt.close();

        // 2. 제조요청 이력 등록 (진행현황 기본값 '요청')
        String insertSql = "INSERT INTO work_order_requests "
                + "(order_id, product_name, target_qty, target_unit, progress_status, requested_by) "
                + "VALUES (?, ?, ?, ?, '요청', ?)";
        pstmt = conn.prepareStatement(insertSql);
        pstmt.setInt(1, orderId);
        pstmt.setString(2, productName);
        pstmt.setDouble(3, targetQty);
        pstmt.setString(4, targetUnit);
        pstmt.setString(5, loginUserId);
        pstmt.executeUpdate();
        pstmt.close();

        conn.commit();
        isSuccess = true;

    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ex) {}
        }
        e.printStackTrace();
        out.print("{\"success\":false,\"message\":\"제조요청 등록 중 오류가 발생했습니다: "
                + e.getMessage().replace("\"", "'") + "\"}");
        return;
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }

    // 3. 구글챗(Google Chat) 웹훅 알림 전송
    // ⚠ 서버 환경변수 GOOGLE_CHAT_WEBHOOK_URL 에 실제 웹훅 URL을 등록해야 정상 작동합니다.
    //    (Google Chat 스페이스 > 앱 및 통합 > 웹훅 추가 에서 발급)
    String webhookUrl = System.getenv("GOOGLE_CHAT_WEBHOOK_URL");

    // 요청 형식: "{제품명} {제조지시량}{단위}의 제조요청이 등록되었습니다."
    String chatMessage = productName + " " + formatQty(targetQty) + targetUnit + "의 제조요청이 등록되었습니다.";

    if (webhookUrl != null && !webhookUrl.trim().isEmpty()) {
        try {
            sendGoogleChatNotification(webhookUrl, chatMessage);
        } catch (Exception e) {
            // 알림 전송 실패는 요청 등록 자체를 실패로 처리하지 않음 (로그만 남김)
            e.printStackTrace();
        }
    } else {
        System.out.println("[경고] GOOGLE_CHAT_WEBHOOK_URL 환경변수가 설정되지 않아 알림을 보내지 않았습니다.");
    }

    out.print("{\"success\":true,\"message\":\"제조요청이 등록되었습니다.\"}");
%>
<%!
    // 소수점 불필요한 0 제거 (100.000 -> 100)
    private String formatQty(double qty) {
        if (qty == Math.floor(qty)) {
            return String.valueOf((long) qty);
        }
        return String.valueOf(qty);
    }

    // 구글챗 웹훅으로 JSON 메시지 POST 전송
    private void sendGoogleChatNotification(String webhookUrl, String message) throws Exception {
        URL url = new URL(webhookUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setDoOutput(true);
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(5000);

        String escapedMessage = message.replace("\\", "\\\\").replace("\"", "\\\"");
        String payload = "{\"text\":\"" + escapedMessage + "\"}";

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = payload.getBytes("UTF-8");
            os.write(input, 0, input.length);
        }

        int responseCode = conn.getResponseCode();
        if (responseCode < 200 || responseCode >= 300) {
            System.out.println("[구글챗 알림 실패] responseCode=" + responseCode);
        }
        conn.disconnect();
    }
%>
