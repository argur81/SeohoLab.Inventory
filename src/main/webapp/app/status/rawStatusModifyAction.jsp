<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    // ★ alert 및 페이지 한글 깨짐 방지를 위한 응답 인코딩 설정 추가
    response.setContentType("text/html; charset=UTF-8");
    response.setCharacterEncoding("UTF-8");

    // 세션에서 로그인한 사용자 아이디 가져오기
    String loginUserId = (String) session.getAttribute("userId");
    if (loginUserId == null || loginUserId.trim().isEmpty()) {
        loginUserId = (String) session.getAttribute("loginId");
    }

    // 1. PK 수신
    String itemIdStr = request.getParameter("itemId");
    if (itemIdStr == null || itemIdStr.trim().isEmpty()) {
        itemIdStr = request.getParameter("id");
    }

    int itemId = 0;
    try {
        if (itemIdStr != null && !itemIdStr.trim().isEmpty()) {
            itemId = Integer.parseInt(itemIdStr.trim());
        }
    } catch (NumberFormatException e) {
        itemId = 0;
    }

    if (itemId <= 0) {
        out.println("<script>alert('잘못된 접근입니다. (아이디 누락)'); history.back();</script>");
        return;
    }

    // 2. 파라미터 수신
    String itemCode = request.getParameter("item_code");
    String itemName = request.getParameter("item_name");
    String workOrder1 = request.getParameter("work_order_1");
    String workOrder2 = request.getParameter("work_order_2");
    
    String chemName = request.getParameter("chem_name");
    String inciName = request.getParameter("inci_name");
    String casNo = request.getParameter("cas_no");
    String supplier = request.getParameter("supplier");
    String maker = request.getParameter("maker");
    
    String priceType = request.getParameter("price_type");
    double price = parseDouble(request.getParameter("price"));

    double kgQty1 = parseDouble(request.getParameter("kg_qty_1"));
    String kgUnit1 = request.getParameter("kg_unit_1");
    double kgPrice1 = parseDouble(request.getParameter("kg_price_1"));

    double kgQty2 = parseDouble(request.getParameter("kg_qty_2"));
    String kgUnit2 = request.getParameter("kg_unit_2");
    double kgPrice2 = parseDouble(request.getParameter("kg_price_2"));

    double kgQty3 = parseDouble(request.getParameter("kg_qty_3"));
    String kgUnit3 = request.getParameter("kg_unit_3");
    double kgPrice3 = parseDouble(request.getParameter("kg_price_3"));

    double kgQty4 = parseDouble(request.getParameter("kg_qty_4"));
    String kgUnit4 = request.getParameter("kg_unit_4");
    double kgPrice4 = parseDouble(request.getParameter("kg_price_4"));

    String priceEtc = request.getParameter("price_etc");

    // 원료추가정보
    String extraInfo = request.getParameter("extra_info");

    // Function, Packing 단위, rHLB, HLB
    String func = request.getParameter("func");
    String packingUnit = request.getParameter("packing_unit");
    String packingUnitSelect = request.getParameter("packing_unit_select");
    
    String rHlb = request.getParameter("r_hlb");
    String hlb = request.getParameter("hlb");
    
    // 인증, 유래, 특이사항, 연구실명칭
    String certification = request.getParameter("certification");
    String origin = request.getParameter("origin");
    String note = request.getParameter("note");
    String labName = request.getParameter("lab_name");

    if (itemName == null || itemName.trim().isEmpty()) {
        out.println("<script>alert('상품명을 입력해 주세요.'); history.back();</script>");
        return;
    }

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

        // 중복 체크 (자기 자신 제외)
        String checkSql = "SELECT COUNT(*) FROM items WHERE item_name = ? AND item_id != ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, itemName.trim());
        pstmt.setInt(2, itemId);
        rs = pstmt.executeQuery();

        int duplicateCount = 0;
        if (rs.next()) {
            duplicateCount = rs.getInt(1);
        }
        rs.close();
        pstmt.close();

        if (duplicateCount > 0) {
            out.println("<script>alert('이미 사용 중인 상품명입니다.'); history.back();</script>");
            return;
        }

        // UPDATE 쿼리 수행 (price_range 제거 반영)
        String sql = "UPDATE items SET "
                + "item_code = ?, item_name = ?, work_order_1 = ?, work_order_2 = ?, "
                + "chem_name = ?, inci_name = ?, cas_no = ?, supplier = ?, maker = ?, "
                + "price_type = ?, price = ?, "
                + "kg_qty_1 = ?, kg_unit_1 = ?, kg_price_1 = ?, "
                + "kg_qty_2 = ?, kg_unit_2 = ?, kg_price_2 = ?, "
                + "kg_qty_3 = ?, kg_unit_3 = ?, kg_price_3 = ?, "
                + "kg_qty_4 = ?, kg_unit_4 = ?, kg_price_4 = ?, "
                + "price_etc = ?, "
                + "extra_info = ?, "
                + "func = ?, packing_unit = ?, packing_unit_select = ?, r_hlb = ?, hlb = ?, "
                + "certification = ?, origin = ?, note = ?, lab_name = ?, "
                + "user_id = ?, "
                + "updated_at = CURRENT_TIMESTAMP "
                + "WHERE item_id = ?";

        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, itemCode);
        pstmt.setString(2, itemName.trim());
        pstmt.setString(3, workOrder1);
        pstmt.setString(4, workOrder2);
        
        pstmt.setString(5, chemName);
        pstmt.setString(6, inciName);
        pstmt.setString(7, casNo);
        pstmt.setString(8, supplier);
        pstmt.setString(9, maker);
        
        pstmt.setString(10, priceType);
        pstmt.setDouble(11, price);

        pstmt.setDouble(12, kgQty1);
        pstmt.setString(13, kgUnit1);
        pstmt.setDouble(14, kgPrice1);

        pstmt.setDouble(15, kgQty2);
        pstmt.setString(16, kgUnit2);
        pstmt.setDouble(17, kgPrice2);

        pstmt.setDouble(18, kgQty3);
        pstmt.setString(19, kgUnit3);
        pstmt.setDouble(20, kgPrice3);

        pstmt.setDouble(21, kgQty4);
        pstmt.setString(22, kgUnit4);
        pstmt.setDouble(23, kgPrice4);

        pstmt.setString(24, priceEtc);

        pstmt.setString(25, extraInfo);

        pstmt.setString(26, func);
        pstmt.setString(27, packingUnit);
        pstmt.setString(28, packingUnitSelect);
        pstmt.setString(29, rHlb);
        pstmt.setString(30, hlb);
        
        pstmt.setString(31, certification);
        pstmt.setString(32, origin);
        pstmt.setString(33, note);
        pstmt.setString(34, labName);
        pstmt.setString(35, loginUserId);
        
        pstmt.setInt(36, itemId);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('원료 정보가 성공적으로 수정되었습니다.'); location.href='rawStatusList.jsp';</script>");
        } else {
            out.println("<script>alert('수정에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('수정 오류: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
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
%>