<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. Request 한글 인코딩 설정
    request.setCharacterEncoding("UTF-8");

    // 2. PK 수신
    String itemIdStr = request.getParameter("itemId");
    if (itemIdStr == null || itemIdStr.trim().isEmpty()) {
        itemIdStr = request.getParameter("item_id");
    }
    if (itemIdStr == null || itemIdStr.trim().isEmpty()) {
        itemIdStr = request.getParameter("id");
    }

    int itemId = 0;
    try {
        if (itemIdStr != null && !itemIdStr.trim().isEmpty()) {
            itemId = Integer.parseInt(itemIdStr.trim());
        }
    } catch (NumberFormatException e) {
        itemId = 0;
    }

    if (itemId <= 0) {
        out.println("<script>alert('잘못된 접근입니다. (아이디 누락)'); history.back();</script>");
        return;
    }

    // 3. Form 파라미터 수신
    String itemName = request.getParameter("item_name");
    String workOrder1 = request.getParameter("work_order_1");
    String workOrder2 = request.getParameter("work_order_2");
    String workOrder3 = request.getParameter("work_order_3");

    // 현재 재고 수량 파라미터 (hidden으로 전달)
    double stockQtyT = parseDouble(request.getParameter("stock_qty_t"));
    double stockQtyKg = parseDouble(request.getParameter("stock_qty_kg"));
    double stockQtyG = parseDouble(request.getParameter("stock_qty_g"));
    double stockQtyMg = parseDouble(request.getParameter("stock_qty_mg"));

    // 최소 재고 수량 파라미터
    double minQtyT = parseDouble(request.getParameter("min_qty_t"));
    double minQtyKg = parseDouble(request.getParameter("min_qty_kg"));
    double minQtyG = parseDouble(request.getParameter("min_qty_g"));
    double minQtyMg = parseDouble(request.getParameter("min_qty_mg"));

    // 4. 수치 단위 완전 동기화 (kg 기준으로 총량 계산)
    double baseStockKg = (stockQtyT * 1000.0) + stockQtyKg + (stockQtyG / 1000.0) + (stockQtyMg / 1000000.0);
    if (baseStockKg > 0) {
        stockQtyKg = (stockQtyKg > 0) ? stockQtyKg : baseStockKg;
        stockQtyT = stockQtyKg / 1000.0;
        stockQtyG = stockQtyKg * 1000.0;
        stockQtyMg = stockQtyKg * 1000000.0;
    }

    double baseMinKg = 0.0;
    if (minQtyKg > 0) baseMinKg = minQtyKg;
    else if (minQtyT > 0) baseMinKg = minQtyT * 1000.0;
    else if (minQtyG > 0) baseMinKg = minQtyG / 1000.0;
    else if (minQtyMg > 0) baseMinKg = minQtyMg / 1000000.0;

    minQtyKg = baseMinKg;
    minQtyT = baseMinKg / 1000.0;
    minQtyG = baseMinKg * 1000.0;
    minQtyMg = baseMinKg * 1000000.0;

    double totalStockKg = baseStockKg;
    double totalMinKg = baseMinKg;

    // 5. 필수값 검증
    if (itemName == null || itemName.trim().isEmpty()) {
        out.println("<script>alert('원료명을 입력해 주세요.'); history.back();</script>");
        return;
    }

    // 6. DB 접속 및 UPDATE 실행
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

        // [중복 체크] 나 자신(item_id)을 제외하고 동일 원료명이 존재하는지 확인
        String checkSql = "SELECT COUNT(*) FROM items WHERE item_name = ? AND item_id != ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, itemName.trim());
        pstmt.setInt(2, itemId);
        rs = pstmt.executeQuery();

        int duplicateCount = 0;
        if (rs.next()) {
            duplicateCount = rs.getInt(1);
        }
        rs.close();
        pstmt.close();

        if (duplicateCount > 0) {
            out.println("<script>alert('이미 사용 중인 원료명입니다.'); history.back();</script>");
            return;
        }

        // 재고 값이 0으로 넘어왔다면 DB에서 기존 값 유지
        if (totalStockKg == 0.0) {
            String stockSql = "SELECT total_stock_kg, stock_qty_t, stock_qty_kg, stock_qty_g, stock_qty_mg FROM items WHERE item_id = ?";
            pstmt = conn.prepareStatement(stockSql);
            pstmt.setInt(1, itemId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                totalStockKg = rs.getDouble("total_stock_kg");
                stockQtyT = rs.getDouble("stock_qty_t");
                stockQtyKg = rs.getDouble("stock_qty_kg");
                stockQtyG = rs.getDouble("stock_qty_g");
                stockQtyMg = rs.getDouble("stock_qty_mg");
            }
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        }

        // ★ [SQL 수정] items 테이블에 존재하지 않는 lot_number, date 관련 컬럼 제거!
        String sql = "UPDATE items SET "
                + "item_name = ?, work_order_1 = ?, work_order_2 = ?, work_order_3 = ?, "
                + "stock_qty_t = ?, stock_qty_kg = ?, stock_qty_g = ?, stock_qty_mg = ?, "
                + "min_qty_t = ?, min_qty_kg = ?, min_qty_g = ?, min_qty_mg = ?, "
                + "total_stock_kg = ?, total_min_kg = ?, "
                + "updated_at = CURRENT_TIMESTAMP "
                + "WHERE item_id = ?";

        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, itemName.trim());
        pstmt.setString(2, workOrder1 != null ? workOrder1.trim() : "");
        pstmt.setString(3, workOrder2 != null ? workOrder2.trim() : "");
        pstmt.setString(4, workOrder3 != null ? workOrder3.trim() : "");

        pstmt.setDouble(5, stockQtyT);
        pstmt.setDouble(6, stockQtyKg);
        pstmt.setDouble(7, stockQtyG);
        pstmt.setDouble(8, stockQtyMg);

        pstmt.setDouble(9, minQtyT);
        pstmt.setDouble(10, minQtyKg);
        pstmt.setDouble(11, minQtyG);
        pstmt.setDouble(12, minQtyMg);

        pstmt.setDouble(13, totalStockKg);
        pstmt.setDouble(14, totalMinKg);

        pstmt.setInt(15, itemId);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('성공적으로 수정되었습니다.'); location.href='rawMaterialStockList.jsp';</script>");
        } else {
            out.println("<script>alert('수정에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('수정 중 오류 발생: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>

<%!
    private double parseDouble(String str) {
        if (str == null || str.trim().isEmpty()) return 0.0;
        try { return Double.parseDouble(str.replaceAll(",", "")); } catch (Exception e) { return 0.0; }
    }
%>