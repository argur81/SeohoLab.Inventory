<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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

        if ("RAW".equals(category)) {
            // 1. 원료: out_qty (t, kg, g, mg) 각 차감 수량 받기
            String outQtyTStr = request.getParameter("out_qty_t");
            String outQtyKgStr = request.getParameter("out_qty_kg");
            String outQtyGStr = request.getParameter("out_qty_g");
            String outQtyMgStr = request.getParameter("out_qty_mg");

            double outT = (outQtyTStr != null && !outQtyTStr.isEmpty()) ? Double.parseDouble(outQtyTStr) : 0;
            double outKg = (outQtyKgStr != null && !outQtyKgStr.isEmpty()) ? Double.parseDouble(outQtyKgStr) : 0;
            double outG = (outQtyGStr != null && !outQtyGStr.isEmpty()) ? Double.parseDouble(outQtyGStr) : 0;
            double outMg = (outQtyMgStr != null && !outQtyMgStr.isEmpty()) ? Double.parseDouble(outQtyMgStr) : 0;

            // kg 단위로 차감 총합 계산 (1t = 1000kg, 1g = 0.001kg, 1mg = 0.000001kg)
            double subtractedTotalKg = (outT * 1000) + outKg + (outG / 1000) + (outMg / 1000000);

            // 각 단위별 재고 및 kg 총합 재고 차감(-)
            sql = "UPDATE items SET "
                + "  stock_qty_t = stock_qty_t - ?, "
                + "  stock_qty_kg = stock_qty_kg - ?, "
                + "  stock_qty_g = stock_qty_g - ?, "
                + "  stock_qty_mg = stock_qty_mg - ?, "
                + "  total_stock_kg = total_stock_kg - ?, "
                + "  updated_at = CURRENT_TIMESTAMP "
                + "WHERE item_name = ?";

            pstmt = conn.prepareStatement(sql);
            pstmt.setDouble(1, outT);
            pstmt.setDouble(2, outKg);
            pstmt.setDouble(3, outG);
            pstmt.setDouble(4, outMg);
            pstmt.setDouble(5, subtractedTotalKg);
            pstmt.setString(6, itemName.trim());

        } else if ("PRODUCT".equals(category)) {
            // 2. 완제품: stock_qty (개수) 차감(-)
            String outQtyStr = request.getParameter("out_qty");
            int outQty = (outQtyStr != null && !outQtyStr.isEmpty()) ? Integer.parseInt(outQtyStr) : 0;

            sql = "UPDATE products SET "
                + "  stock_qty = stock_qty - ?, "
                + "  updated_at = CURRENT_TIMESTAMP "
                + "WHERE item_name = ?";

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, outQty);
            pstmt.setString(2, itemName.trim());

        } else if ("SUBSIDIARY".equals(category)) {
            // 3. 부자재: stock_qty (개수) 차감(-)
            String outQtyStr = request.getParameter("out_qty");
            int outQty = (outQtyStr != null && !outQtyStr.isEmpty()) ? Integer.parseInt(outQtyStr) : 0;

            sql = "UPDATE subsidiary SET "
                + "  stock_qty = stock_qty - ?, "
                + "  updated_at = CURRENT_TIMESTAMP "
                + "WHERE item_name = ?";

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, outQty);
            pstmt.setString(2, itemName.trim());
        }

        result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('출고 등록(재고 차감)이 완료되었습니다.'); location.href='releaseRegist.jsp';</script>");
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