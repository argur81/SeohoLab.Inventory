<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. 파라미터 수신 (PK 및 기본 정보)
    String itemIdStr = request.getParameter("itemId");
    String category = request.getParameter("category");
    String itemName = request.getParameter("item_name");
    
    String workOrder1 = request.getParameter("work_order_1");
    String workOrder2 = request.getParameter("work_order_2");
    String workOrder3 = request.getParameter("work_order_3");
    
    String lotNumber = request.getParameter("lot_number");
    
    String receiptDate = request.getParameter("receipt_date");
    String manufactureDate = request.getParameter("manufacture_date");
    String expirationDate = request.getParameter("expiration_date");

    // 필수값 유효성 검사
    if (itemIdStr == null || itemIdStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
    int itemId = Integer.parseInt(itemIdStr);

    // 2. 수치 파라미터 수신 (Null/Empty 처리 헬퍼 파싱)
    // 콤마(,)가 포함되어 넘어올 경우에 대비해 replaceAll(",", "") 적용
    autoParseQty parseQty = new autoParseQty();
    
    BigDecimal inQtyT  = parseQty.toBD(request.getParameter("in_qty_t"));
    BigDecimal inQtyKg = parseQty.toBD(request.getParameter("in_qty_kg"));
    BigDecimal inQtyG  = parseQty.toBD(request.getParameter("in_qty_g"));
    BigDecimal inQtyMg = parseQty.toBD(request.getParameter("in_qty_mg"));

    BigDecimal minQtyT  = parseQty.toBD(request.getParameter("min_qty_t"));
    BigDecimal minQtyKg = parseQty.toBD(request.getParameter("min_qty_kg"));
    BigDecimal minQtyG  = parseQty.toBD(request.getParameter("min_qty_g"));
    BigDecimal minQtyMg = parseQty.toBD(request.getParameter("min_qty_mg"));

    // 3. 통합 kg 수치 자동 계산 (1t = 1000kg / 1g = 0.001kg / 1mg = 0.000001kg)
    // 입력된 단위 중 우선순위가 높거나(혹은 합산 기준) 환산하여 계산
    BigDecimal totalStockKg = BigDecimal.ZERO;
    if (inQtyKg.compareTo(BigDecimal.ZERO) > 0) {
        totalStockKg = inQtyKg;
    } else if (inQtyT.compareTo(BigDecimal.ZERO) > 0) {
        totalStockKg = inQtyT.multiply(new BigDecimal("1000"));
    } else if (inQtyG.compareTo(BigDecimal.ZERO) > 0) {
        totalStockKg = inQtyG.divide(new BigDecimal("1000"), 6, RoundingMode.HALF_UP);
    } else if (inQtyMg.compareTo(BigDecimal.ZERO) > 0) {
        totalStockKg = inQtyMg.divide(new BigDecimal("1000000"), 6, RoundingMode.HALF_UP);
    }

    BigDecimal totalMinKg = BigDecimal.ZERO;
    if (minQtyKg.compareTo(BigDecimal.ZERO) > 0) {
        totalMinKg = minQtyKg;
    } else if (minQtyT.compareTo(BigDecimal.ZERO) > 0) {
        totalMinKg = minQtyT.multiply(new BigDecimal("1000"));
    } else if (minQtyG.compareTo(BigDecimal.ZERO) > 0) {
        totalMinKg = minQtyG.divide(new BigDecimal("1000"), 6, RoundingMode.HALF_UP);
    } else if (minQtyMg.compareTo(BigDecimal.ZERO) > 0) {
        totalMinKg = minQtyMg.divide(new BigDecimal("1000000"), 6, RoundingMode.HALF_UP);
    }

    // 4. DB UPDATE 실행
    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        // updated_at 은 NOW()로 자동 갱신
        String sql = "UPDATE items SET "
                + "item_name = ?, work_order_1 = ?, work_order_2 = ?, work_order_3 = ?, "
                + "lot_number = ?, receipt_date = ?, manufacture_date = ?, expiration_date = ?, "
                + "in_qty_t = ?, in_qty_kg = ?, in_qty_g = ?, in_qty_mg = ?, "
                + "min_qty_t = ?, min_qty_kg = ?, min_qty_g = ?, min_qty_mg = ?, "
                + "total_stock_kg = ?, total_min_kg = ?, updated_at = NOW() "
                + "WHERE item_id = ?";

        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, itemName);
        pstmt.setString(2, workOrder1);
        pstmt.setString(3, workOrder2);
        pstmt.setString(4, workOrder3);
        pstmt.setString(5, lotNumber);
        
        // Date 날짜 빈값 예외 처리
        pstmt.setObject(6, (receiptDate != null && !receiptDate.isEmpty()) ? Date.valueOf(receiptDate) : null);
        pstmt.setObject(7, (manufactureDate != null && !manufactureDate.isEmpty()) ? Date.valueOf(manufactureDate) : null);
        pstmt.setObject(8, (expirationDate != null && !expirationDate.isEmpty()) ? Date.valueOf(expirationDate) : null);

        // 단위 수치 세팅
        pstmt.setBigDecimal(9, inQtyT);
        pstmt.setBigDecimal(10, inQtyKg);
        pstmt.setBigDecimal(11, inQtyG);
        pstmt.setBigDecimal(12, inQtyMg);

        pstmt.setBigDecimal(13, minQtyT);
        pstmt.setBigDecimal(14, minQtyKg);
        pstmt.setBigDecimal(15, minQtyG);
        pstmt.setBigDecimal(16, minQtyMg);

        // 총합 kg 세팅
        pstmt.setBigDecimal(17, totalStockKg);
        pstmt.setBigDecimal(18, totalMinKg);

        pstmt.setInt(19, itemId);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('성공적으로 수정되었습니다.'); location.href='rawMaterialStockList.jsp';</script>");
        } else {
            out.println("<script>alert('수정에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>

<%!
    // 수치 문자열을 BigDecimal로 안전하게 변환해 주는 클래스
    public static class autoParseQty {
        public BigDecimal toBD(String str) {
            if (str == null) return BigDecimal.ZERO;
            str = str.replaceAll(",", "").trim();
            if (str.isEmpty()) return BigDecimal.ZERO;
            try {
                return new BigDecimal(str);
            } catch (Exception e) {
                return BigDecimal.ZERO;
            }
        }
    }
%>