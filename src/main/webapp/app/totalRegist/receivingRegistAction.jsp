<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    // ★ 응답 인코딩 설정 추가 (alert 한글 깨짐 방지)
    response.setContentType("text/html; charset=UTF-8");
    response.setCharacterEncoding("UTF-8");

    // 세션에서 로그인한 사용자 아이디 가져오기
    String loginUserId = (String) session.getAttribute("userId");
    if (loginUserId == null || loginUserId.trim().isEmpty()) {
        loginUserId = (String) session.getAttribute("loginId"); 
    }

    String category = request.getParameter("category");
    String itemName = request.getParameter("item_name");
    String lotNumber = request.getParameter("lot_number");

    if (category == null || itemName == null || itemName.trim().isEmpty()) {
        out.println("<script>alert('품목명을 입력해 주세요.'); history.back();</script>");
        return;
    }

    // ★ DB URL에 한글 캐릭터셋 옵션 추가
    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmtCheck = null;
    PreparedStatement pstmtMaster = null;
    PreparedStatement pstmtLot = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        conn.setAutoCommit(false);

        String receiptDate = request.getParameter("receipt_date");
        String manufactureDate = request.getParameter("manufacture_date");
        String expirationDate = request.getParameter("expiration_date");
        String cleanLot = (lotNumber != null && !lotNumber.trim().isEmpty()) ? lotNumber.trim() : "NO_LOT";

        if ("RAW".equals(category)) {
            pstmtCheck = conn.prepareStatement("SELECT COUNT(*) FROM items WHERE item_name = ?");
            pstmtCheck.setString(1, itemName.trim());
            rs = pstmtCheck.executeQuery();
            boolean exists = (rs.next() && rs.getInt(1) > 0);
            rs.close(); 
            pstmtCheck.close();

            if (!exists) {
                conn.rollback();
                out.println("<script>alert('등록되지 않은 원료입니다.\\n[신규등록] 메뉴에서 품목을 먼저 등록한 후 이용해 주세요.'); history.back();</script>");
                return;
            }

            double inT  = parseDouble(request.getParameter("in_qty_t"));
            double inKg = parseDouble(request.getParameter("in_qty_kg"));
            double inG  = parseDouble(request.getParameter("in_qty_g"));
            double inMg = parseDouble(request.getParameter("in_qty_mg"));
            
            double totalInputKg = (inT * 1000.0) + inKg + (inG / 1000.0) + (inMg / 1000000.0);

            double calcT  = totalInputKg / 1000.0;
            double calcKg = totalInputKg;
            double calcG  = totalInputKg * 1000.0;
            double calcMg = totalInputKg * 1000000.0;

            String sqlMaster = "UPDATE items SET "
                            + "  stock_qty_t = stock_qty_t + ?, "
                            + "  stock_qty_kg = stock_qty_kg + ?, "
                            + "  stock_qty_g = stock_qty_g + ?, "
                            + "  stock_qty_mg = stock_qty_mg + ?, "
                            + "  last_stock_user_id = ?, "
                            + "  updated_at = CURRENT_TIMESTAMP "
                            + "WHERE item_name = ?";
            pstmtMaster = conn.prepareStatement(sqlMaster);
            pstmtMaster.setDouble(1, calcT);
            pstmtMaster.setDouble(2, calcKg);
            pstmtMaster.setDouble(3, calcG);
            pstmtMaster.setDouble(4, calcMg);
            pstmtMaster.setString(5, loginUserId);
            pstmtMaster.setString(6, itemName.trim());
            pstmtMaster.executeUpdate();

            String sqlLot = "INSERT INTO item_lots "
                        + "(item_name, lot_number, receipt_date, manufacture_date, expiration_date, "
                        + " stock_qty_t, stock_qty_kg, stock_qty_g, stock_qty_mg) "
                        + "VALUES (?, ?, NULLIF(?, ''), NULLIF(?, ''), NULLIF(?, ''), ?, ?, ?, ?) "
                        + "ON DUPLICATE KEY UPDATE "
                        + "  stock_qty_t = stock_qty_t + VALUES(stock_qty_t), "
                        + "  stock_qty_kg = stock_qty_kg + VALUES(stock_qty_kg), "
                        + "  stock_qty_g = stock_qty_g + VALUES(stock_qty_g), "
                        + "  stock_qty_mg = stock_qty_mg + VALUES(stock_qty_mg), "
                        + "  receipt_date = COALESCE(VALUES(receipt_date), receipt_date), "
                        + "  manufacture_date = COALESCE(VALUES(manufacture_date), manufacture_date), "
                        + "  expiration_date = COALESCE(VALUES(expiration_date), expiration_date), "
                        + "  updated_at = CURRENT_TIMESTAMP";

            pstmtLot = conn.prepareStatement(sqlLot);
            pstmtLot.setString(1, itemName.trim());
            pstmtLot.setString(2, cleanLot);
            pstmtLot.setString(3, receiptDate);
            pstmtLot.setString(4, manufactureDate);
            pstmtLot.setString(5, expirationDate);
            pstmtLot.setDouble(6, calcT);
            pstmtLot.setDouble(7, calcKg);
            pstmtLot.setDouble(8, calcG);
            pstmtLot.setDouble(9, calcMg);
            pstmtLot.executeUpdate();

        } else if ("PRODUCT".equals(category)) {
            pstmtCheck = conn.prepareStatement("SELECT COUNT(*) FROM products WHERE item_name = ?");
            pstmtCheck.setString(1, itemName.trim());
            rs = pstmtCheck.executeQuery();
            boolean exists = (rs.next() && rs.getInt(1) > 0);
            rs.close(); 
            pstmtCheck.close();

            if (!exists) {
                conn.rollback();
                out.println("<script>alert('등록되지 않은 제품입니다.\\n[신규등록] 메뉴에서 품목을 먼저 등록한 후 이용해 주세요.'); history.back();</script>");
                return;
            }

            int inQty = parseInt(request.getParameter("in_qty"));

            String sqlMaster = "UPDATE products SET stock_qty = stock_qty + ?, last_stock_user_id = ?, updated_at = CURRENT_TIMESTAMP WHERE item_name = ?";
            pstmtMaster = conn.prepareStatement(sqlMaster);
            pstmtMaster.setInt(1, inQty);
            pstmtMaster.setString(2, loginUserId);
            pstmtMaster.setString(3, itemName.trim());
            pstmtMaster.executeUpdate();

            String sqlLot = "INSERT INTO product_lots "
                        + "(item_name, lot_number, manufacture_date, expiration_date, stock_qty) "
                        + "VALUES (?, ?, NULLIF(?, ''), NULLIF(?, ''), ?) "
                        + "ON DUPLICATE KEY UPDATE "
                        + "  stock_qty = stock_qty + VALUES(stock_qty), "
                        + "  manufacture_date = COALESCE(VALUES(manufacture_date), manufacture_date), "
                        + "  expiration_date = COALESCE(VALUES(expiration_date), expiration_date), "
                        + "  updated_at = CURRENT_TIMESTAMP";
            pstmtLot = conn.prepareStatement(sqlLot);
            pstmtLot.setString(1, itemName.trim());
            pstmtLot.setString(2, cleanLot);
            pstmtLot.setString(3, manufactureDate);
            pstmtLot.setString(4, expirationDate);
            pstmtLot.setInt(5, inQty);
            pstmtLot.executeUpdate();

        } else if ("SUBSIDIARY".equals(category)) {
            pstmtCheck = conn.prepareStatement("SELECT COUNT(*) FROM subsidiary WHERE item_name = ?");
            pstmtCheck.setString(1, itemName.trim());
            rs = pstmtCheck.executeQuery();
            boolean exists = (rs.next() && rs.getInt(1) > 0);
            rs.close(); 
            pstmtCheck.close();

            if (!exists) {
                conn.rollback();
                out.println("<script>alert('등록되지 않은 부자재입니다.\\n[신규등록] 메뉴에서 품목을 먼저 등록한 후 이용해 주세요.'); history.back();</script>");
                return;
            }

            int inQty = parseInt(request.getParameter("in_qty"));

            String sqlMaster = "UPDATE subsidiary SET stock_qty = stock_qty + ?, last_stock_user_id = ?, updated_at = CURRENT_TIMESTAMP WHERE item_name = ?";
            pstmtMaster = conn.prepareStatement(sqlMaster);
            pstmtMaster.setInt(1, inQty);
            pstmtMaster.setString(2, loginUserId);
            pstmtMaster.setString(3, itemName.trim());
            pstmtMaster.executeUpdate();
        }

        conn.commit();
        out.println("<script>alert('입고 등록이 완료되었습니다.'); location.href='receivingRegist.jsp';</script>");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch(Exception ex) {}
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmtCheck != null) try { pstmtCheck.close(); } catch(Exception e){}
        if (pstmtMaster != null) try { pstmtMaster.close(); } catch(Exception e){}
        if (pstmtLot != null) try { pstmtLot.close(); } catch(Exception e){}
        if (conn != null) {
            try { conn.setAutoCommit(true); conn.close(); } catch(Exception e){}
        }
    }
%>
<%!
    private double parseDouble(String str) {
        if (str == null || str.trim().isEmpty()) return 0.0;
        try { return Double.parseDouble(str.replaceAll(",", "")); } catch (Exception e) { return 0.0; }
    }

    private int parseInt(String str) {
        if (str == null || str.trim().isEmpty()) return 0;
        try { return Integer.parseInt(str.replaceAll(",", "")); } catch (Exception e) { return 0; }
    }
%>