<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String itemName = request.getParameter("item_name");
    String category = request.getParameter("category"); // 구분 파라미터 추가
    if (itemName == null) itemName = "";
    if (category == null) category = "RAW"; // 기본값 RAW

    StringBuilder json = new StringBuilder("[");

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

        String sql = "";
        if ("PRODUCT".equals(category)) {
            // 제품 Lot 조회 (필요 시 테이블명 product_lots로 수정)
            sql = "SELECT lot_number, stock_qty FROM product_lots WHERE item_name = ? ORDER BY lot_number DESC";
        } else {
            // 원료 Lot 조회
            sql = "SELECT lot_number, stock_qty_t, stock_qty_kg, stock_qty_g, stock_qty_mg "
                + "FROM item_lots WHERE item_name = ? ORDER BY lot_number DESC";
        }

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, itemName.trim());
        rs = pstmt.executeQuery();

        boolean isFirst = true;
        while (rs.next()) {
            if (!isFirst) json.append(",");

            String lotNumber = rs.getString("lot_number");
            
            json.append("{");
            json.append("\"lot_number\":\"").append(lotNumber != null ? lotNumber.replace("\"", "\\\"") : "").append("\",");
            
            if ("PRODUCT".equals(category)) {
                // 제품은 개수(qty)만 처리
                json.append("\"stock_qty\":").append(rs.getInt("stock_qty"));
            } else {
                // 원료는 단위별 재고 처리
                json.append("\"stock_qty_t\":").append(rs.getDouble("stock_qty_t")).append(",");
                json.append("\"stock_qty_kg\":").append(rs.getDouble("stock_qty_kg")).append(",");
                json.append("\"stock_qty_g\":").append(rs.getDouble("stock_qty_g")).append(",");
                json.append("\"stock_qty_mg\":").append(rs.getDouble("stock_qty_mg"));
            }
            json.append("}");
            isFirst = false;
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }

    json.append("]");
    out.print(json.toString());
%>