<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String category = request.getParameter("category"); // RAW, PRODUCT, SUBSIDIARY
    String itemName = request.getParameter("item_name");
    
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
        conn.setAutoCommit(false); // 트랜잭션 시작

        boolean isSuccess = false;

        if ("RAW".equals(category)) {
            int idx = 0;
            int lotCount = 0;

            double sumTotalKg = 0; // items의 total_stock_kg에서 뺄 총 kg 합산[cite: 6]
            double sumT = 0;       // items의 stock_qty_t에서 뺄 총 t 합산[cite: 6]
            double sumKg = 0;      // items의 stock_qty_kg에서 뺄 총 kg 합산[cite: 6]
            double sumG = 0;       // items의 stock_qty_g에서 뺄 총 g 합산[cite: 6]
            double sumMg = 0;      // items의 stock_qty_mg에서 뺄 총 mg 합산[cite: 6]

            while (true) {
                String lotNumber = request.getParameter("lotUsages[" + idx + "].lot_number");
                if (lotNumber == null) break;

                double lT = Double.parseDouble(request.getParameter("lotUsages[" + idx + "].t").replace(",", ""));
                double lKg = Double.parseDouble(request.getParameter("lotUsages[" + idx + "].kg").replace(",", ""));
                double lG = Double.parseDouble(request.getParameter("lotUsages[" + idx + "].g").replace(",", ""));
                double lMg = Double.parseDouble(request.getParameter("lotUsages[" + idx + "].mg").replace(",", ""));
                
                // 개별 Lot의 kg 기준 총합 계산[cite: 5, 6]
                double lTotalKg = (lT * 1000) + lKg + (lG / 1000) + (lMg / 1000000);

                // 이번 루프에서 출고된 양들을 총합에 누적
                sumT += lT;
                sumKg += lKg;
                sumG += lG;
                sumMg += lMg;
                sumTotalKg += lTotalKg;

                // 개별 Lot 단위 차감 쿼리 실행 (`item_lots`에서 total_stock_kg 삭제 완료)
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

            // 2. 개별 Lot들의 차감 총합을 `items` (원료 마스터) 테이블에 반영[cite: 5, 6]
            int totalUpdateResult = 0;
            if (lotCount > 0) {
                String totalSql = "UPDATE items SET "
                    + "  stock_qty_t = stock_qty_t - ?, "
                    + "  stock_qty_kg = stock_qty_kg - ?, "
                    + "  stock_qty_g = stock_qty_g - ?, "
                    + "  stock_qty_mg = stock_qty_mg - ?, "
                    + "  total_stock_kg = total_stock_kg - ?, "
                    + "  updated_at = CURRENT_TIMESTAMP "
                    + "WHERE TRIM(item_name) = ?";

                pstmt = conn.prepareStatement(totalSql);
                pstmt.setDouble(1, sumT);
                pstmt.setDouble(2, sumKg);
                pstmt.setDouble(3, sumG);
                pstmt.setDouble(4, sumMg);
                pstmt.setDouble(5, sumTotalKg);
                pstmt.setString(6, itemName.trim());
                
                totalUpdateResult = pstmt.executeUpdate();
                pstmt.close();

                // 만약 items 테이블에 해당 원료 데이터가 없다면 신규 INSERT 처리[cite: 5, 6]
                if (totalUpdateResult == 0) {
                    String insertSql = "INSERT INTO items (category, item_name, stock_qty_t, stock_qty_kg, stock_qty_g, stock_qty_mg, total_stock_kg) "
                        + "VALUES ('RAW', ?, -?, -?, -?, -?, -?)";
                    pstmt = conn.prepareStatement(insertSql);
                    pstmt.setString(1, itemName.trim());
                    pstmt.setDouble(2, sumT);
                    pstmt.setDouble(3, sumKg);
                    pstmt.setDouble(4, sumG);
                    pstmt.setDouble(5, sumMg);
                    pstmt.setDouble(6, sumTotalKg);
                    totalUpdateResult = pstmt.executeUpdate();
                    pstmt.close();
                }
            }

            if (lotCount > 0 || totalUpdateResult > 0) {
                isSuccess = true;
            }

        } else if ("PRODUCT".equals(category)) {
            int idx = 0;
            int lotCount = 0;
            int sumQty = 0; // products 마스터 테이블에서 뺄 총 개수 합산

            while (true) {
                String lotNumber = request.getParameter("lotUsages[" + idx + "].lot_number");
                if (lotNumber == null) break;

                int lQty = Integer.parseInt(request.getParameter("lotUsages[" + idx + "].qty").replace(",", ""));
                
                sumQty += lQty;

                // 1. 개별 제품 Lot 단위 차감 쿼리 실행
                String lotSql = "UPDATE product_lots SET "
                    + "  stock_qty = stock_qty - ?, "
                    + "  updated_at = CURRENT_TIMESTAMP "
                    + "WHERE TRIM(lot_number) = ? AND TRIM(item_name) = ?";

                pstmt = conn.prepareStatement(lotSql);
                pstmt.setInt(1, lQty);
                pstmt.setString(2, lotNumber.trim());
                pstmt.setString(3, itemName.trim());
                
                int lotUpdateResult = pstmt.executeUpdate();
                pstmt.close();

                if (lotUpdateResult > 0) {
                    lotCount++;
                }
                idx++;
            }

            // 2. 개별 Lot들의 차감 총합을 `products` (제품 마스터) 테이블에 반영
            int totalUpdateResult = 0;
            if (lotCount > 0) {
                String totalSql = "UPDATE products SET "
                    + "  stock_qty = stock_qty - ?, "
                    + "  updated_at = CURRENT_TIMESTAMP "
                    + "WHERE TRIM(item_name) = ?";

                pstmt = conn.prepareStatement(totalSql);
                pstmt.setInt(1, sumQty);
                pstmt.setString(2, itemName.trim());
                
                totalUpdateResult = pstmt.executeUpdate();
                pstmt.close();

                // 만약 products 테이블에 해당 데이터가 없다면 신규 INSERT 처리
                if (totalUpdateResult == 0) {
                    String insertSql = "INSERT INTO products (item_name, stock_qty) VALUES (?, -?)";
                    pstmt = conn.prepareStatement(insertSql);
                    pstmt.setString(1, itemName.trim());
                    pstmt.setInt(2, sumQty);
                    totalUpdateResult = pstmt.executeUpdate();
                    pstmt.close();
                }
            }

            if (lotCount > 0 || totalUpdateResult > 0) {
                isSuccess = true;
            }

        } else if ("SUBSIDIARY".equals(category)) {
            String outQtyStr = request.getParameter("out_qty");
            int outQty = (outQtyStr != null && !outQtyStr.trim().isEmpty()) ? Integer.parseInt(outQtyStr.replace(",", "")) : 0;

            String sql = "UPDATE subsidiary SET stock_qty = stock_qty - ?, updated_at = CURRENT_TIMESTAMP WHERE TRIM(item_name) = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, outQty);
            pstmt.setString(2, itemName.trim());
            if (pstmt.executeUpdate() > 0) isSuccess = true;
            pstmt.close();
        }

        if (isSuccess) {
            conn.commit();
            out.println("<script>alert('출고 등록 및 재고 차감이 완료되었습니다.'); location.href='releaseRegist.jsp';</script>");
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