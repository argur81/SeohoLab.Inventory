<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
    response.setCharacterEncoding("UTF-8");

    // 세션에서 로그인한 사용자 아이디 가져오기
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

    // [제품 용량] 및 [단위] 파라미터 받기
    String productCapacityStr = request.getParameter("product_capacity");
    String capacityUnit = request.getParameter("capacity_unit");

    double productCapacity = 0;
    if (productCapacityStr != null && !productCapacityStr.trim().isEmpty()) {
        try {
            productCapacity = Double.parseDouble(productCapacityStr.replace(",", ""));
        } catch (NumberFormatException e) {
            productCapacity = 0;
        }
    }

    // 배열로 전달된 부자재 정보 받기
    String[] itemNames = request.getParameterValues("item_name[]");
    String[] subsidiaryTypes = request.getParameterValues("subsidiary_type[]");
    String[] outQtys = request.getParameterValues("out_qty[]");

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb?useUnicode=true&characterEncoding=utf8";
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

        // 1. work_order_requests 상태를 '충진중'으로 업데이트
        String updateStatusSql = "UPDATE work_order_requests SET progress_status = '충진중', updated_at = CURRENT_TIMESTAMP WHERE request_id = ?";
        pstmt = conn.prepareStatement(updateStatusSql);
        pstmt.setInt(1, requestId);
        int statusUpdateResult = pstmt.executeUpdate();
        pstmt.close();

        if (statusUpdateResult > 0) {
            isSuccess = true;
        }

        // ★ 제품 용량/단위를 work_order_making에 저장
        //   (사전 조건) work_order_making 테이블에 아래 컬럼이 있어야 합니다.
        //   ALTER TABLE work_order_making
        //     ADD COLUMN product_capacity DECIMAL(10,2) DEFAULT NULL COMMENT '제품 용량',
        //     ADD COLUMN capacity_unit VARCHAR(20) DEFAULT NULL COMMENT '용량 단위 (mL, L 등)';
        String updateCapacitySql = "UPDATE work_order_making SET product_capacity = ?, capacity_unit = ?, updated_at = CURRENT_TIMESTAMP WHERE request_id = ?";
        pstmt = conn.prepareStatement(updateCapacitySql);
        pstmt.setDouble(1, productCapacity);
        pstmt.setString(2, capacityUnit != null ? capacityUnit.trim() : "");
        pstmt.setInt(3, requestId);
        pstmt.executeUpdate();
        pstmt.close();

        // 2. 기존 등록된 부자재 내역이 있다면 삭제 후 재등록 (중복 방지용)
        String deleteSubSql = "DELETE FROM work_order_subsidiary WHERE request_id = ?";
        pstmt = conn.prepareStatement(deleteSubSql);
        pstmt.setInt(1, requestId);
        pstmt.executeUpdate();
        pstmt.close();

        // 3. 부자재 정보 저장 (예상 사용량 기록만 남김)
        //    ※ 재고 차감은 이 단계에서 하지 않음. 부자재는 충진시작 이후에도 입고될 수 있으므로
        //      실사용량이 확정되지 않은 이 시점에는 subsidiary.stock_qty를 건드리지 않는다.
        //      (실제 소모 확정 시점에 별도의 차감 로직을 두어야 함)
        if (itemNames != null) {
            for (int i = 0; i < itemNames.length; i++) {
                String itemName = itemNames[i];
                String subType = (subsidiaryTypes != null && subsidiaryTypes.length > i) ? subsidiaryTypes[i] : "";
                String qtyStr = (outQtys != null && outQtys.length > i) ? outQtys[i] : "0";

                if (itemName != null && !itemName.trim().isEmpty() && qtyStr != null && !qtyStr.trim().isEmpty()) {
                    int outQty = Integer.parseInt(qtyStr.replace(",", ""));

                    // work_order_subsidiary 테이블에 예상 사용 부자재 내역 저장 (재고 차감 없음)
                    String insertSubSql = "INSERT INTO work_order_subsidiary (request_id, item_name, subsidiary_type, out_qty) VALUES (?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(insertSubSql);
                    pstmt.setInt(1, requestId);
                    pstmt.setString(2, itemName.trim());
                    pstmt.setString(3, subType.trim());
                    pstmt.setInt(4, outQty);
                    pstmt.executeUpdate();
                    pstmt.close();
                }
            }
        }

        if (isSuccess) {
            conn.commit();
            out.println("<script>alert('충진이 시작되었습니다.'); location.href='../workOrderProgressList.jsp';</script>");
        } else {
            conn.rollback();
            out.println("<script>alert('충진 시작 처리 실패: 지시서 정보를 찾을 수 없습니다.'); history.back();</script>");
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
