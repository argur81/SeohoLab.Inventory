<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String category = request.getParameter("category");
    if (category == null || category.trim().isEmpty()) category = "RAW";

    String itemName = request.getParameter("item_name");
    String workOrder1 = request.getParameter("work_order_1");
    String workOrder2 = request.getParameter("work_order_2");
    String workOrder3 = request.getParameter("work_order_3");

    // 폼에서는 in_qty_* 로 넘어오지만, 마스터 테이블의 초기 재고(stock_qty_*)로 바로 저장합니다.
    double stockQtyT = parseDouble(request.getParameter("in_qty_t"));
    double stockQtyKg = parseDouble(request.getParameter("in_qty_kg"));
    double stockQtyG = parseDouble(request.getParameter("in_qty_g"));
    double stockQtyMg = parseDouble(request.getParameter("in_qty_mg"));

    double minQtyT = parseDouble(request.getParameter("min_qty_t"));
    double minQtyKg = parseDouble(request.getParameter("min_qty_kg"));
    double minQtyG = parseDouble(request.getParameter("min_qty_g"));
    double minQtyMg = parseDouble(request.getParameter("min_qty_mg"));

    // ★ kg 단위 통합 환산 연산
    double totalStockKg = (stockQtyT * 1000.0) + stockQtyKg + (stockQtyG / 1000.0) + (stockQtyMg / 1000000.0);
    double totalMinKg = (minQtyT * 1000.0) + minQtyKg + (minQtyG / 1000.0) + (minQtyMg / 1000000.0);

    if (itemName == null || itemName.trim().isEmpty()) {
        out.println("<script>alert('품목명을 입력해 주세요.'); history.back();</script>");
        return;
    }

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        // ★ [품목 등록 중복 체크] 동일한 품목명이 DB에 있는지 사전 검사
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
            out.println("<script>alert('이미 등록된 품목명입니다.'); history.back();</script>");
            return;
        }

        // ★ 덜어낸 컬럼(Lot, 날짜, in_qty)들을 제외한 깔끔한 INSERT 문
        String sql = "INSERT INTO items "
                + "(category, item_name, work_order_1, work_order_2, work_order_3, "
                + "stock_qty_t, stock_qty_kg, stock_qty_g, stock_qty_mg, "
                + "min_qty_t, min_qty_kg, min_qty_g, min_qty_mg, "
                + "total_stock_kg, total_min_kg, "
                + "created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";

        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, category);
        pstmt.setString(2, itemName.trim());
        pstmt.setString(3, workOrder1 != null ? workOrder1.trim() : "");
        pstmt.setString(4, workOrder2 != null ? workOrder2.trim() : "");
        pstmt.setString(5, workOrder3 != null ? workOrder3.trim() : "");

        pstmt.setDouble(6, stockQtyT);
        pstmt.setDouble(7, stockQtyKg);
        pstmt.setDouble(8, stockQtyG);
        pstmt.setDouble(9, stockQtyMg);

        pstmt.setDouble(10, minQtyT);
        pstmt.setDouble(11, minQtyKg);
        pstmt.setDouble(12, minQtyG);
        pstmt.setDouble(13, minQtyMg);

        pstmt.setDouble(14, totalStockKg);
        pstmt.setDouble(15, totalMinKg);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('성공적으로 등록되었습니다.'); location.href='rawMaterialStockList.jsp';</script>");
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
    // 날짜 관련 메서드는 불필요해져서 제거했습니다.
    private double parseDouble(String str) {
        if (str == null || str.trim().isEmpty()) return 0.0;
        try { return Double.parseDouble(str.replaceAll(",", "")); } catch (Exception e) { return 0.0; }
    }
%>