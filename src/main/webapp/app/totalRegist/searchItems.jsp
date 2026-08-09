<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String category = request.getParameter("category");
    String keyword = request.getParameter("keyword");

    if (category == null || keyword == null || keyword.trim().isEmpty()) {
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

    List<String> itemList = new ArrayList<String>();

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        String sql = "";
        
        if ("RAW".equals(category)) {
            sql = "SELECT DISTINCT item_name FROM items WHERE item_name LIKE ? LIMIT 10";
        } else if ("PRODUCT".equals(category)) {
            sql = "SELECT DISTINCT item_name FROM products WHERE item_name LIKE ? LIMIT 10";
        } else if ("SUBSIDIARY".equals(category)) {
            sql = "SELECT DISTINCT item_name FROM subsidiary WHERE item_name LIKE ? LIMIT 10";
        }

        if (!sql.isEmpty()) {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "%" + keyword.trim() + "%");
            rs = pstmt.executeQuery();

            while (rs.next()) {
                String name = rs.getString("item_name");
                if (name != null) {
                    itemList.add(name);
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }

    // json-simple 없이 수동 JSON 문자열 생성
    StringBuilder json = new StringBuilder();
    json.append("[");
    for (int i = 0; i < itemList.size(); i++) {
        String escaped = itemList.get(i).replace("\\", "\\\\").replace("\"", "\\\"");
        json.append("\"").append(escaped).append("\"");
        if (i < itemList.size() - 1) {
            json.append(",");
        }
    }
    json.append("]");

    out.print(json.toString());
%>