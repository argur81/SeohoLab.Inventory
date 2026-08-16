<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 세션에서 로그인한 사용자 아이디 가져오기
    String loginUserId = (String) session.getAttribute("userId");
    if (loginUserId == null || loginUserId.trim().isEmpty()) {
        loginUserId = (String) session.getAttribute("loginId"); // 대체 세션 키 확인용
    }

    // 1. 파라미터 수신
    String itemIdStr = request.getParameter("itemId");
    String itemCode = request.getParameter("item_code");
    String itemName = request.getParameter("item_name");
    String workOrder1 = request.getParameter("work_order_1");
    String workOrder2 = request.getParameter("work_order_2");

    // 최소 재고 물량
    double minQtyT = parseDouble(request.getParameter("min_qty_t"));
    double minQtyKg = parseDouble(request.getParameter("min_qty_kg"));
    double minQtyG = parseDouble(request.getParameter("min_qty_g"));
    double minQtyMg = parseDouble(request.getParameter("min_qty_mg"));
    
    // total_min_kg 계산
    double totalMinKg = (minQtyT * 1000.0) + minQtyKg + (minQtyG / 1000.0) + (minQtyMg / 1000000.0);

    if (itemIdStr == null || itemName == null || itemName.trim().isEmpty()) {
        out.println("<script>alert('필수 정보를 확인해 주세요.'); history.back();</script>");
        return;
    }

    int itemId = Integer.parseInt(itemIdStr);

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        // ★ 수정: user_id 대신 재고현황용 last_stock_user_id를 업데이트하도록 변경
        String sql = "UPDATE items SET "
                   + "item_code = ?, item_name = ?, work_order_1 = ?, work_order_2 = ?, "
                   + "min_qty_t = ?, min_qty_kg = ?, min_qty_g = ?, min_qty_mg = ?, total_min_kg = ?, "
                   + "last_stock_user_id = ?, " 
                   + "updated_at = CURRENT_TIMESTAMP "
                   + "WHERE item_id = ?";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, itemCode);
        pstmt.setString(2, itemName.trim());
        pstmt.setString(3, workOrder1);
        pstmt.setString(4, workOrder2);
        pstmt.setDouble(5, minQtyT);
        pstmt.setDouble(6, minQtyKg);
        pstmt.setDouble(7, minQtyG);
        pstmt.setDouble(8, minQtyMg);
        pstmt.setDouble(9, totalMinKg);
        pstmt.setString(10, loginUserId); // 재고현황 수정자 아이디 반영
        pstmt.setInt(11, itemId);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('수정되었습니다.'); location.href='rawMaterialStockList.jsp';</script>");
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
    private double parseDouble(String str) {
        if (str == null || str.trim().isEmpty()) return 0.0;
        try { return Double.parseDouble(str.replaceAll(",", "")); } catch (Exception e) { return 0.0; }
    }
%>