<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String category = request.getParameter("category");
    String itemName = request.getParameter("item_name");
    String keyword = request.getParameter("keyword");

    List<String> list = new ArrayList<String>();

    if (keyword == null || keyword.trim().isEmpty()) {
        out.print("[]");
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

        String tableName = "item_lots";
        if ("PRODUCT".equals(category)) {
            tableName = "product_lots";
        }

        if (!"SUBSIDIARY".equals(category)) {
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT DISTINCT lot_number FROM ").append(tableName).append(" WHERE lot_number LIKE ? ");
            
            if (itemName != null && !itemName.trim().isEmpty()) {
                sql.append(" AND item_name = ? ");
            }
            sql.append(" ORDER BY lot_number DESC LIMIT 20");

            pstmt = conn.prepareStatement(sql.toString());
            pstmt.setString(1, "%" + keyword.trim() + "%");
            if (itemName != null && !itemName.trim().isEmpty()) {
                pstmt.setString(2, itemName.trim());
            }

            rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(rs.getString("lot_number"));
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }

    // JSON 배열 직접 생성 (라이브러리 의존성 제거)
    StringBuilder json = new StringBuilder("[");
    for (int i = 0; i < list.size(); i++) {
        json.append("\"").append(list.get(i).replace("\"", "\\\"")).append("\"");
        if (i < list.size() - 1) json.append(",");
    }
    json.append("]");

    out.print(json.toString());
%>