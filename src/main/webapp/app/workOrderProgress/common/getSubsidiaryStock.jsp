<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 부자재명 + 종류로 현재 재고(stock_qty) 조회
    // 위치: src/main/webapp/app/totalRegist/getSubsidiaryStock.jsp
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    String itemName = request.getParameter("item_name");
    String subsidiaryType = request.getParameter("subsidiary_type");

    int stockQty = 0;
    boolean found = false;

    if (itemName != null && !itemName.trim().isEmpty()) {
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

            String sql = "SELECT stock_qty FROM subsidiary WHERE TRIM(item_name) = ? AND TRIM(subsidiary_type) = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, itemName.trim());
            pstmt.setString(2, subsidiaryType != null ? subsidiaryType.trim() : "");
            rs = pstmt.executeQuery();

            if (rs.next()) {
                stockQty = rs.getInt("stock_qty");
                found = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch(Exception e){}
            if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
            if (conn != null) try { conn.close(); } catch(Exception e){}
        }
    }

    out.print("{\"found\":" + found + ",\"stock_qty\":" + stockQty + "}");
%>
