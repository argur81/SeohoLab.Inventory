<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    // ★ 응답 인코딩 설정 추가
    response.setContentType("text/html; charset=UTF-8");
    response.setCharacterEncoding("UTF-8");

    // 세션에서 로그인한 사용자 아이디 가져오기
    String loginUserId = (String) session.getAttribute("userId");
    if (loginUserId == null || loginUserId.trim().isEmpty()) {
        loginUserId = (String) session.getAttribute("loginId"); 
    }

    String category = request.getParameter("category"); // RAW, PRODUCT, SUBSIDIARY
    String itemName = request.getParameter("item_name");
    
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
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        conn.setAutoCommit(false);

        boolean isSuccess = false;

        if ("RAW".equals(category)) {
            int idx = 0;
            int lotCount = 0;

            double sumT = 0;       
            double sumKg = 0;      
            double sumG = 0;       
            double sumMg = 0;      

            while (true) {
                String lotNumber = request.getParameter("lotUsages[" + idx + "].lot_number");
                if (lotNumber == null) break;

                double lT = Double.parseDouble(request.getParameter("lotUsages[" + idx + "].t").replace(",", ""));
                double lKg = Double.parseDouble(request.getParameter("lotUsages[" + idx + "].kg").replace(",", ""));
                double lG = Double.parseDouble(request.getParameter("lotUsages[" + idx + "].g").replace(",", ""));
                double lMg = Double.parseDouble(request.getParameter("lotUsages[" + idx + "].mg").replace(",", ""));

                sumT += lT;
                sumKg += lKg;
                sumG += lG;
                sumMg += lMg;

                String lotSql = "UPDATE item_lots SET "
                    + "  stock_qty_t = stock_qty_t - ?, "
                    + "  stock_qty_kg = stock_qty_kg - ?, "
                    + "  stock_qty_g = stock_qty_g - ?, "
                    + "  stock_qty_mg = stock_qty_mg - ?, "
                    + "  updated_at = CURRENT_TIMESTAMP "
                    + "WHERE TRIM(lot_number) = ? AND TRIM(item_name) = ?";

                pstmt = conn.prepareStatement(lotSql);
                pstmt.setDouble(1, lT);
                pstmt.setDouble(2, lKg);
                pstmt.setDouble(3, lG);
                pstmt.setDouble(4, lMg);
                pstmt.setString(5, lotNumber.trim());
                pstmt.setString(6, itemName.trim());
                
                int lotUpdateResult = pstmt.executeUpdate();
                pstmt.close();

                if (lotUpdateResult > 0) {
                    lotCount++;
                }
                idx++;
            }

            int totalUpdateResult = 0;
            if (lotCount > 0) {
                String totalSql = "UPDATE items SET "
                    + "  stock_qty_t = stock_qty_t - ?, "
                    + "  stock_qty_kg = stock_qty_kg - ?, "
                    + "  stock_qty_g = stock_qty_g - ?, "
                    + "  stock_qty_mg = stock_qty_mg - ?, "
                    + "  last_stock_user_id = ?, "
                    + "  updated_at = CURRENT_TIMESTAMP "
                    + "WHERE TRIM(item_name) = ?";

                pstmt = conn.prepareStatement(totalSql);
                pstmt.setDouble(1, sumT);
                pstmt.setDouble(2, sumKg);
                pstmt.setDouble(3, sumG);
                pstmt.setDouble(4, sumMg);
                pstmt.setString(5, loginUserId);
                pstmt.setString(6, itemName.trim());
                
                totalUpdateResult = pstmt.executeUpdate();
                pstmt.close();

                if (totalUpdateResult == 0) {
                    String insertSql = "INSERT INTO items (category, item_name, stock_qty_t, stock_qty_kg, stock_qty_g, stock_qty_mg, last_stock_user_id) "
                        + "VALUES ('RAW', ?, -?, -?, -?, -?, ?)";
                    pstmt = conn.prepareStatement(insertSql);
                    pstmt.setString(1, itemName.trim());
                    pstmt.setDouble(2, sumT);
                    pstmt.setDouble(3, sumKg);
                    pstmt.setDouble(4, sumG);
                    pstmt.setDouble(5, sumMg);
                    pstmt.setString(6, loginUserId);
                    totalUpdateResult = pstmt.executeUpdate();
                    pstmt.close();
                }
            }

            if (lotCount > 0 || totalUpdateResult > 0) {
                isSuccess = true;
            }

        } else if ("PRODUCT".equals(category)) {
            String outQtyStr = request.getParameter("out_qty");
            int outQty = (outQtyStr != null && !outQtyStr.trim().isEmpty()) ? Integer.parseInt(outQtyStr.replace(",", "")) : 0;

            String sql = "UPDATE products SET stock_qty = stock_qty - ?, last_stock_user_id = ?, updated_at = CURRENT_TIMESTAMP WHERE TRIM(item_name) = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, outQty);
            pstmt.setString(2, loginUserId);
            pstmt.setString(3, itemName.trim());
            if (pstmt.executeUpdate() > 0) isSuccess = true;
            pstmt.close();

        } else if ("SUBSIDIARY".equals(category)) {
            String outQtyStr = request.getParameter("out_qty");
            int outQty = (outQtyStr != null && !outQtyStr.trim().isEmpty()) ? Integer.parseInt(outQtyStr.replace(",", "")) : 0;

            String sql = "UPDATE subsidiary SET stock_qty = stock_qty - ?, last_stock_user_id = ?, updated_at = CURRENT_TIMESTAMP WHERE TRIM(item_name) = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, outQty);
            pstmt.setString(2, loginUserId);
            pstmt.setString(3, itemName.trim());
            if (pstmt.executeUpdate() > 0) isSuccess = true;
            pstmt.close();
        }

        if (isSuccess) {
            conn.commit();
            out.println("<script>alert('사용 등록 및 재고 차감이 완료되었습니다.'); location.href='usedRegist.jsp';</script>");
        } else {
            conn.rollback();
            out.println("<script>alert('등록 실패: 일치하는 품목명 또는 Lot 번호가 없습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch(SQLException ignored) {}
        }
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>