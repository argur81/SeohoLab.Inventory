<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>
<%
    request.setCharacterEncoding("UTF-8");

    String category = request.getParameter("category"); // RAW, PRODUCT, SUBSIDIARY
    String itemName = request.getParameter("item_name");
    
    // 필수값 체크
    if (category == null || itemName == null || itemName.trim().isEmpty()) {
        out.println("<script>alert('품목명을 입력해 주세요.'); history.back();</script>");
        return;
    }

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        String sql = "";
        int result = 0;

        // 날짜 파라미터 빈값 처리 함수용 Helper
        String receiptDate = request.getParameter("receipt_date");
        String manufactureDate = request.getParameter("manufacture_date");
        String expirationDate = request.getParameter("expiration_date");

        if ("RAW".equals(category)) {
            String inQtyTStr = request.getParameter("in_qty_t");
            String inQtyKgStr = request.getParameter("in_qty_kg");
            String inQtyGStr = request.getParameter("in_qty_g");
            String inQtyMgStr = request.getParameter("in_qty_mg");

            double inT = (inQtyTStr != null && !inQtyTStr.isEmpty()) ? Double.parseDouble(inQtyTStr) : 0;
            double inKg = (inQtyKgStr != null && !inQtyKgStr.isEmpty()) ? Double.parseDouble(inQtyKgStr) : 0;
            double inG = (inQtyGStr != null && !inQtyGStr.isEmpty()) ? Double.parseDouble(inQtyGStr) : 0;
            double inMg = (inQtyMgStr != null && !inQtyMgStr.isEmpty()) ? Double.parseDouble(inQtyMgStr) : 0;

            double addedTotalKg = (inT * 1000) + inKg + (inG / 1000) + (inMg / 1000000);

            sql = "UPDATE items SET "
                + "  stock_qty_t = stock_qty_t + ?, "
                + "  stock_qty_kg = stock_qty_kg + ?, "
                + "  stock_qty_g = stock_qty_g + ?, "
                + "  stock_qty_mg = stock_qty_mg + ?, "
                + "  total_stock_kg = total_stock_kg + ?, "
                + "  lot_number = ?, "
                + "  receipt_date = NULLIF(?, ''), "
                + "  manufacture_date = NULLIF(?, ''), "
                + "  expiration_date = NULLIF(?, ''), "
                + "  updated_at = CURRENT_TIMESTAMP "
                + "WHERE item_name = ?";

            pstmt = conn.prepareStatement(sql);
            pstmt.setDouble(1, inT);
            pstmt.setDouble(2, inKg);
            pstmt.setDouble(3, inG);
            pstmt.setDouble(4, inMg);
            pstmt.setDouble(5, addedTotalKg);
            pstmt.setString(6, request.getParameter("lot_number"));
            pstmt.setString(7, receiptDate);
            pstmt.setString(8, manufactureDate);
            pstmt.setString(9, expirationDate);
            pstmt.setString(10, itemName.trim());

        } else if ("PRODUCT".equals(category)) {
            String inQtyStr = request.getParameter("in_qty");
            int inQty = (inQtyStr != null && !inQtyStr.isEmpty()) ? Integer.parseInt(inQtyStr) : 0;

            sql = "UPDATE products SET "
                + "  stock_qty = stock_qty + ?, "
                + "  lot_number = ?, "
                + "  manufacture_date = NULLIF(?, ''), "
                + "  expiration_date = NULLIF(?, ''), "
                + "  updated_at = CURRENT_TIMESTAMP "
                + "WHERE item_name = ?";

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, inQty);
            pstmt.setString(2, request.getParameter("lot_number"));
            pstmt.setString(3, manufactureDate);
            pstmt.setString(4, expirationDate);
            pstmt.setString(5, itemName.trim());

        } else if ("SUBSIDIARY".equals(category)) {
            String inQtyStr = request.getParameter("in_qty");
            int inQty = (inQtyStr != null && !inQtyStr.isEmpty()) ? Integer.parseInt(inQtyStr) : 0;

            sql = "UPDATE subsidiary SET "
                + "  stock_qty = stock_qty + ?, "
                + "  updated_at = CURRENT_TIMESTAMP "
                + "WHERE item_name = ?";

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, inQty);
            pstmt.setString(2, itemName.trim());
        }

        result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('입고 등록(재고 반영)이 완료되었습니다.'); location.href='receivingRegist.jsp';</script>");
        } else {
            out.println("<script>alert('등록 실패: 신규등록 메뉴에 등록되지 않은 품목명입니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>