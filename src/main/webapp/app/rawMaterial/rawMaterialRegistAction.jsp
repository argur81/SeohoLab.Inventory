<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
    response.setCharacterEncoding("UTF-8");

    // 세션에서 로그인한 사용자 아이디 가져오기
    String loginUserId = (String) session.getAttribute("userId");
    if (loginUserId == null || loginUserId.trim().isEmpty()) {
        loginUserId = (String) session.getAttribute("loginId"); // 대체 세션 키 확인용
    }

    String category = request.getParameter("category");
    if (category == null || category.trim().isEmpty()) category = "RAW";

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

    // price_range는 화면에서 삭제되었으므로 제외 또는 빈 값 처리
    String priceEtc = request.getParameter("price_etc");

    String extraInfo = request.getParameter("extra_info");

    String func = request.getParameter("func");
    
    String packingUnit = request.getParameter("packing_unit");
    String packingUnitSelect = request.getParameter("packing_unit_select");
    
    String rHlb = request.getParameter("r_hlb");
    String hlb = request.getParameter("hlb");
    
    String certification = request.getParameter("certification");
    String origin = request.getParameter("origin");
    String note = request.getParameter("note");
    String labName = request.getParameter("lab_name");

    double minQtyT = parseDouble(request.getParameter("min_qty_t"));
    double minQtyKg = parseDouble(request.getParameter("min_qty_kg"));
    double minQtyG = parseDouble(request.getParameter("min_qty_g"));
    double minQtyMg = parseDouble(request.getParameter("min_qty_mg"));

    double totalMinKg = (minQtyT * 1000.0) + minQtyKg + (minQtyG / 1000.0) + (minQtyMg / 1000000.0);

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

        String checkSql = "SELECT COUNT(*) FROM items WHERE item_name = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, itemName.trim());
        rs = pstmt.executeQuery();

        int duplicateCount = 0;
        if (rs.next()) {
            duplicateCount = rs.getInt(1);
        }
        rs.close();
        pstmt.close();

        if (duplicateCount > 0) {
            out.println("<script>alert('이미 등록된 상품명입니다.'); history.back();</script>");
            return;
        }

        // INSERT 쿼리에서 price_range 컬럼 및 파라미터 제거
        String sql = "INSERT INTO items ("
                + "category, item_code, item_name, work_order_1, work_order_2, "
                + "chem_name, inci_name, cas_no, supplier, maker, "
                + "price_type, price, "
                + "kg_qty_1, kg_unit_1, kg_price_1, "
                + "kg_qty_2, kg_unit_2, kg_price_2, "
                + "kg_qty_3, kg_unit_3, kg_price_3, "
                + "kg_qty_4, kg_unit_4, kg_price_4, "
                + "price_etc, "
                + "extra_info, "
                + "func, packing_unit, packing_unit_select, r_hlb, hlb, "
                + "certification, origin, note, lab_name, "
                + "min_qty_t, min_qty_kg, min_qty_g, min_qty_mg, total_min_kg, "
                + "user_id, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";

        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, category);
        pstmt.setString(2, itemCode);
        pstmt.setString(3, itemName.trim());
        pstmt.setString(4, workOrder1);
        pstmt.setString(5, workOrder2);
        
        pstmt.setString(6, chemName);
        pstmt.setString(7, inciName);
        pstmt.setString(8, casNo);
        pstmt.setString(9, supplier);
        pstmt.setString(10, maker);
        
        pstmt.setString(11, priceType); // '1kg기준', '1g기준', '무게별', '기타' 값이 그대로 저장됨
        pstmt.setDouble(12, price);

        pstmt.setDouble(13, kgQty1);
        pstmt.setString(14, kgUnit1);
        pstmt.setDouble(15, kgPrice1);

        pstmt.setDouble(16, kgQty2);
        pstmt.setString(17, kgUnit2);
        pstmt.setDouble(18, kgPrice2);

        pstmt.setDouble(19, kgQty3);
        pstmt.setString(20, kgUnit3);
        pstmt.setDouble(21, kgPrice3);

        pstmt.setDouble(22, kgQty4);
        pstmt.setString(23, kgUnit4);
        pstmt.setDouble(24, kgPrice4);

        pstmt.setString(25, priceEtc);

        pstmt.setString(26, extraInfo);

        pstmt.setString(27, func);
        pstmt.setString(28, packingUnit);
        pstmt.setString(29, packingUnitSelect);
        pstmt.setString(30, rHlb);
        pstmt.setString(31, hlb);
        
        pstmt.setString(32, certification);
        pstmt.setString(33, origin);
        pstmt.setString(34, note);
        pstmt.setString(35, labName);
        
        pstmt.setDouble(36, minQtyT);
        pstmt.setDouble(37, minQtyKg);
        pstmt.setDouble(38, minQtyG);
        pstmt.setDouble(39, minQtyMg);
        pstmt.setDouble(40, totalMinKg);
        pstmt.setString(41, loginUserId);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('원료가 성공적으로 등록되었습니다.'); location.href='/app/status/rawStatusList.jsp';</script>");
        } else {
            out.println("<script>alert('등록에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('등록 오류: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
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