<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // ============================================================
    // [충진완료] 버튼 처리
    // 1. production_qty(생산수량)만큼 products 총재고 증가
    // 2. product_lots에 제조번호(work_order_making.batch_no) 기준 Lot 재고 반영
    // 3. work_order_requests.progress_status 를 '생산완료'로 변경
    // ※ 이미 '생산완료' 상태인 건은 재적용하지 않도록 가드 처리
    // ============================================================
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
    response.setCharacterEncoding("UTF-8");

    String loginUserId = (String) session.getAttribute("userId");
    if (loginUserId == null || loginUserId.trim().isEmpty()) {
        loginUserId = (String) session.getAttribute("loginId");
    }

    String requestIdStr = request.getParameter("request_id");
    if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
    int requestId = Integer.parseInt(requestIdStr);

    String productionQtyStr = request.getParameter("production_qty");
    int productionQty = 0;
    try {
        if (productionQtyStr != null && !productionQtyStr.trim().isEmpty()) {
            productionQty = Integer.parseInt(productionQtyStr.replace(",", "").trim());
        }
    } catch (Exception e) {
        productionQty = 0;
    }

    if (productionQty <= 0) {
        out.println("<script>alert('생산수량을 올바르게 입력해 주세요.'); history.back();</script>");
        return;
    }

    String manufactureDate = request.getParameter("manufacture_date");
    String expirationDate = request.getParameter("expiration_date");

    // 배열로 전달된 부자재 정보 받기 (기존 충진 화면 표시용 - 재고 반영은 충진시작 단계에서 이미 처리됨)
    String[] itemNames = request.getParameterValues("item_name[]");
    String[] subsidiaryTypes = request.getParameterValues("subsidiary_type[]");
    String[] outQtys = request.getParameterValues("out_qty[]");

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
        conn.setAutoCommit(false);

        // 0. 이미 생산완료 처리된 건인지 확인 (중복 재고증가 방지) + 제품명 확보
        String checkSql = "SELECT product_name, progress_status FROM work_order_requests WHERE request_id = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();

        String productName = "";
        String currentStatus = "";
        if (rs.next()) {
            productName = rs.getString("product_name");
            currentStatus = rs.getString("progress_status") != null ? rs.getString("progress_status") : "";
        } else {
            conn.rollback();
            out.println("<script>alert('해당 요청 내역을 찾을 수 없습니다.'); history.back();</script>");
            return;
        }
        rs.close();
        pstmt.close();

        if ("생산완료".equals(currentStatus)) {
            conn.rollback();
            out.println("<script>alert('이미 생산완료 처리된 항목입니다.'); location.href='workOrderProgressList.jsp';</script>");
            return;
        }

        if (productName == null || productName.trim().isEmpty()) {
            conn.rollback();
            out.println("<script>alert('제품명 정보를 확인할 수 없습니다.'); history.back();</script>");
            return;
        }

        // 1. 제조번호(Lot) 조회 (work_order_making.batch_no) - 완제품 Lot번호로 그대로 사용
        String batchNo = "";
        String batchSql = "SELECT batch_no FROM work_order_making WHERE request_id = ?";
        pstmt = conn.prepareStatement(batchSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            batchNo = rs.getString("batch_no");
        }
        rs.close();
        pstmt.close();
        if (batchNo == null || batchNo.trim().isEmpty()) {
            batchNo = "NO_LOT";
        }

        // 2. products 총재고 증가 (미리 등록되어 있는 제품이어야 함 - productRegist.jsp에서 신규등록)
        String updateProductSql = "UPDATE products SET stock_qty = stock_qty + ?, last_stock_user_id = ?, updated_at = CURRENT_TIMESTAMP WHERE TRIM(item_name) = ?";
        pstmt = conn.prepareStatement(updateProductSql);
        pstmt.setInt(1, productionQty);
        pstmt.setString(2, loginUserId);
        pstmt.setString(3, productName.trim());
        int productUpdateResult = pstmt.executeUpdate();
        pstmt.close();

        if (productUpdateResult == 0) {
            // 등록되지 않은 제품이면 자동으로 신규 등록 (종류는 기본값 '기타'로 생성, 추후 productModify.jsp에서 수정 가능)
            String insertProductSql = "INSERT INTO products (category, product_type, item_name, stock_qty, min_qty, last_stock_user_id) "
                    + "VALUES ('PRODUCT', '기타', ?, ?, 0, ?)";
            pstmt = conn.prepareStatement(insertProductSql);
            pstmt.setString(1, productName.trim());
            pstmt.setInt(2, productionQty);
            pstmt.setString(3, loginUserId);
            pstmt.executeUpdate();
            pstmt.close();
        }

        // 3. product_lots Lot별 재고 반영 (같은 Lot이 이미 있으면 수량 합산)
        String lotSql = "INSERT INTO product_lots (item_name, lot_number, manufacture_date, expiration_date, stock_qty) "
                + "VALUES (?, ?, NULLIF(?, ''), NULLIF(?, ''), ?) "
                + "ON DUPLICATE KEY UPDATE "
                + "  stock_qty = stock_qty + VALUES(stock_qty), "
                + "  manufacture_date = COALESCE(VALUES(manufacture_date), manufacture_date), "
                + "  expiration_date = COALESCE(VALUES(expiration_date), expiration_date), "
                + "  updated_at = CURRENT_TIMESTAMP";
        pstmt = conn.prepareStatement(lotSql);
        pstmt.setString(1, productName.trim());
        pstmt.setString(2, batchNo.trim());
        pstmt.setString(3, manufactureDate);
        pstmt.setString(4, expirationDate);
        pstmt.setInt(5, productionQty);
        pstmt.executeUpdate();
        pstmt.close();

        // 4. 진행현황을 생산완료로 변경
        String updateStatusSql = "UPDATE work_order_requests SET progress_status = '생산완료', updated_at = CURRENT_TIMESTAMP WHERE request_id = ?";
        pstmt = conn.prepareStatement(updateStatusSql);
        pstmt.setInt(1, requestId);
        pstmt.executeUpdate();
        pstmt.close();

        conn.commit();
        out.println("<script>alert('생산이 완료되어 제품 재고(총재고 및 Lot)에 반영되었습니다.'); location.href='workOrderProgressList.jsp';</script>");

    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch(SQLException ignored) {}
        }
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>
