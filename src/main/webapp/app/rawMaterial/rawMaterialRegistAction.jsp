<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String category = request.getParameter("category");
    if (category == null || category.trim().isEmpty()) category = "RAW";

    String itemName = request.getParameter("item_name");
    String workOrder1 = request.getParameter("work_order_1");
    String workOrder2 = request.getParameter("work_order_2");
    String workOrder3 = request.getParameter("work_order_3");
    String lotNumber = request.getParameter("lot_number");
    String receiptDate = request.getParameter("receipt_date");
    String manufactureDate = request.getParameter("manufacture_date");
    String expirationDate = request.getParameter("expiration_date");

    // 수량 수신
    double inQtyT = parseDouble(request.getParameter("in_qty_t"));
    double inQtyKg = parseDouble(request.getParameter("in_qty_kg"));
    double inQtyG = parseDouble(request.getParameter("in_qty_g"));
    double inQtyMg = parseDouble(request.getParameter("in_qty_mg"));

    double minQtyT = parseDouble(request.getParameter("min_qty_t"));
    double minQtyKg = parseDouble(request.getParameter("min_qty_kg"));
    double minQtyG = parseDouble(request.getParameter("min_qty_g"));
    double minQtyMg = parseDouble(request.getParameter("min_qty_mg"));

    // 현재 재고 = 입고 수량
    double stockQtyT = inQtyT;
    double stockQtyKg = inQtyKg;
    double stockQtyG = inQtyG;
    double stockQtyMg = inQtyMg;

    // ★ kg 단위 통합 환산 연산 (1t = 1000kg, 1g = 0.001kg, 1mg = 0.000001kg)
    double totalStockKg = (stockQtyT * 1000.0) + stockQtyKg + (stockQtyG / 1000.0) + (stockQtyMg / 1000000.0);
    double totalMinKg = (minQtyT * 1000.0) + minQtyKg + (minQtyG / 1000.0) + (minQtyMg / 1000000.0);

    if (itemName == null || itemName.trim().isEmpty()) {
        out.println("<script>alert('원료명을 입력해 주세요.'); history.back();</script>");
        return;
    }

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

        // ★ [원료 등록 중복 체크] 동일한 원료명이 DB에 있는지 사전 검사
        String checkSql = "SELECT COUNT(*) FROM items WHERE item_name = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, itemName.trim());
        rs = pstmt.executeQuery();

        int duplicateCount = 0;
        if (rs.next()) {
            duplicateCount = rs.getInt(1);
        }
        rs.close();
        pstmt.close();

        if (duplicateCount > 0) {
            out.println("<script>alert('이미 등록된 원료명입니다.'); history.back();</script>");
            return;
        }

        // ★ 중복이 없을 경우 INSERT 진행
        String sql = "INSERT INTO items "
                   + "(category, item_name, work_order_1, work_order_2, work_order_3, lot_number, "
                   + "receipt_date, manufacture_date, expiration_date, "
                   + "in_qty_t, in_qty_kg, in_qty_g, in_qty_mg, "
                   + "stock_qty_t, stock_qty_kg, stock_qty_g, stock_qty_mg, "
                   + "min_qty_t, min_qty_kg, min_qty_g, min_qty_mg, "
                   + "total_stock_kg, total_min_kg, "
                   + "created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";

        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, category);
        pstmt.setString(2, itemName.trim());
        pstmt.setString(3, workOrder1 != null ? workOrder1.trim() : "");
        pstmt.setString(4, workOrder2 != null ? workOrder2.trim() : "");
        pstmt.setString(5, workOrder3 != null ? workOrder3.trim() : "");
        pstmt.setString(6, lotNumber != null ? lotNumber.trim() : "");

        setDateOrNull(pstmt, 7, receiptDate);
        setDateOrNull(pstmt, 8, manufactureDate);
        setDateOrNull(pstmt, 9, expirationDate);

        pstmt.setDouble(10, inQtyT);
        pstmt.setDouble(11, inQtyKg);
        pstmt.setDouble(12, inQtyG);
        pstmt.setDouble(13, inQtyMg);

        pstmt.setDouble(14, stockQtyT);
        pstmt.setDouble(15, stockQtyKg);
        pstmt.setDouble(16, stockQtyG);
        pstmt.setDouble(17, stockQtyMg);

        pstmt.setDouble(18, minQtyT);
        pstmt.setDouble(19, minQtyKg);
        pstmt.setDouble(20, minQtyG);
        pstmt.setDouble(21, minQtyMg);

        pstmt.setDouble(22, totalStockKg);
        pstmt.setDouble(23, totalMinKg);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('원료가 성공적으로 등록되었습니다.'); location.href='rawMaterialStockList.jsp';</script>");
        } else {
            out.println("<script>alert('등록에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('등록 오류: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
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

    private void setDateOrNull(PreparedStatement pstmt, int index, String dateStr) throws SQLException {
        if (dateStr != null && !dateStr.trim().isEmpty()) pstmt.setString(index, dateStr);
        else pstmt.setNull(index, java.sql.Types.DATE);
    }
%>