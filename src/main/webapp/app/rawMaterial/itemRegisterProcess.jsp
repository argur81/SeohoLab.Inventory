<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. 한글 깨짐 방지
    request.setCharacterEncoding("UTF-8");

    // 2. 폼 파라미터 수신 (기본 정보)
    String category = request.getParameter("category");
    String itemName = request.getParameter("item_name");
    String workOrder1 = request.getParameter("work_order_1");
    String workOrder2 = request.getParameter("work_order_2");
    String workOrder3 = request.getParameter("work_order_3");
    String lotNumber = request.getParameter("lot_number");
    
    String receiptDate = request.getParameter("receipt_date");
    String manufactureDate = request.getParameter("manufacture_date");
    String expirationDate = request.getParameter("expiration_date");

    // 빈 날짜 값이 들어올 경우 NULL 처리를 위해 null 파싱
    if (receiptDate != null && receiptDate.trim().isEmpty()) receiptDate = null;
    if (manufactureDate != null && manufactureDate.trim().isEmpty()) manufactureDate = null;
    if (expirationDate != null && expirationDate.trim().isEmpty()) expirationDate = null;

    // 3. 수량 파라미터 파싱 메서드용 헬퍼 (null 및 빈값 0 처리)
    double inQtyT = parseDoubleSafely(request.getParameter("in_qty_t"));
    double inQtyKg = parseDoubleSafely(request.getParameter("in_qty_kg"));
    double inQtyG = parseDoubleSafely(request.getParameter("in_qty_g"));
    double inQtyMg = parseDoubleSafely(request.getParameter("in_qty_mg"));

    double minQtyT = parseDoubleSafely(request.getParameter("min_qty_t"));
    double minQtyKg = parseDoubleSafely(request.getParameter("min_qty_kg"));
    double minQtyG = parseDoubleSafely(request.getParameter("min_qty_g"));
    double minQtyMg = parseDoubleSafely(request.getParameter("min_qty_mg"));

    // 신규 등록 시 현재 재고(stock)는 입고 물량(in)과 동일하게 시작
    double stockQtyT = inQtyT;
    double stockQtyKg = inQtyKg;
    double stockQtyG = inQtyG;
    double stockQtyMg = inQtyMg;

    // 4. 대시보드 비교용 통합 kg 환산 계산
    // 공식: (t * 1000) + kg + (g / 1000) + (mg / 1000000)
    double totalStockKg = (stockQtyT * 1000.0) + stockQtyKg + (stockQtyG / 1000.0) + (stockQtyMg / 1000000.0);
    double totalMinKg = (minQtyT * 1000.0) + minQtyKg + (minQtyG / 1000.0) + (minQtyMg / 1000000.0);

    // 5. DB 연결 설정
    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        String sql = "INSERT INTO items ("
                   + "  category, item_name, work_order_1, work_order_2, work_order_3, "
                   + "  lot_number, receipt_date, manufacture_date, expiration_date, "
                   + "  in_qty_t, in_qty_kg, in_qty_g, in_qty_mg, "
                   + "  stock_qty_t, stock_qty_kg, stock_qty_g, stock_qty_mg, "
                   + "  min_qty_t, min_qty_kg, min_qty_g, min_qty_mg, "
                   + "  total_stock_kg, total_min_kg "
                   + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, category);
        pstmt.setString(2, itemName);
        pstmt.setString(3, workOrder1);
        pstmt.setString(4, workOrder2);
        pstmt.setString(5, workOrder3);
        pstmt.setString(6, lotNumber);
        
        // 날짜 바인딩 (null 체크)
        if (receiptDate != null) pstmt.setDate(7, java.sql.Date.valueOf(receiptDate));
        else pstmt.setNull(7, java.sql.Types.DATE);

        if (manufactureDate != null) pstmt.setDate(8, java.sql.Date.valueOf(manufactureDate));
        else pstmt.setNull(8, java.sql.Types.DATE);

        if (expirationDate != null) pstmt.setDate(9, java.sql.Date.valueOf(expirationDate));
        else pstmt.setNull(9, java.sql.Types.DATE);

        // 입고 수량
        pstmt.setDouble(10, inQtyT);
        pstmt.setDouble(11, inQtyKg);
        pstmt.setDouble(12, inQtyG);
        pstmt.setDouble(13, inQtyMg);

        // 현재 재고 수량
        pstmt.setDouble(14, stockQtyT);
        pstmt.setDouble(15, stockQtyKg);
        pstmt.setDouble(16, stockQtyG);
        pstmt.setDouble(17, stockQtyMg);

        // 최소 재고 수량
        pstmt.setDouble(18, minQtyT);
        pstmt.setDouble(19, minQtyKg);
        pstmt.setDouble(20, minQtyG);
        pstmt.setDouble(21, minQtyMg);

        // 환산 총 kg
        pstmt.setDouble(22, totalStockKg);
        pstmt.setDouble(23, totalMinKg);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            // 카테고리에 따른 목록 페이지 이동 리다이렉트 처리
            String targetPage = "rawStock.jsp"; // 기본값 (원료 재고)
            if ("PRODUCT".equals(category)) targetPage = "productStock.jsp";
            else if ("SUB".equals(category)) targetPage = "subStock.jsp";
%>
            <script>
                alert("신규 등록이 완료되었습니다.");
                location.href = "<%= targetPage %>";
            </script>
<%
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
        <script>
            alert("등록 중 오류가 발생했습니다: <%= e.getMessage() %>");
            history.back();
        </script>
<%
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>

<%!
    // 숫자 파싱 실패 시 0.0 반환 함수
    private double parseDoubleSafely(String str) {
        if (str == null || str.trim().isEmpty()) {
            return 0.0;
        }
        try {
            return Double.parseDouble(str.trim());
        } catch (NumberFormatException e) {
            return 0.0;
        }
    }
%>