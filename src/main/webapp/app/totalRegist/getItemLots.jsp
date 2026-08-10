<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String itemName = request.getParameter("item_name");
    if (itemName == null) itemName = "";

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

        // Lot 번호와 함께 단위별 현재 재고 컬럼 조회
        String sql = "SELECT lot_number, stock_qty_t, stock_qty_kg, stock_qty_g, stock_qty_mg "
                   + "FROM item_lots "
                   + "WHERE item_name = ? "
                   + "ORDER BY lot_number DESC";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, itemName.trim());

        rs = pstmt.executeQuery();

        boolean isFirst = true;
        while (rs.next()) {
            double t = rs.getDouble("stock_qty_t");
            double kg = rs.getDouble("stock_qty_kg");
            double g = rs.getDouble("stock_qty_g");
            double mg = rs.getDouble("stock_qty_mg");

            // 모든 단위의 재고가 0인 경우 해당 Lot은 결과에서 제외
            if (t == 0 && kg == 0 && g == 0 && mg == 0) {
                continue;
            }

            if (!isFirst) json.append(",");
            
            String lotNumber = rs.getString("lot_number");
            if (lotNumber == null) lotNumber = "";

            json.append("{");
            json.append("\"lot_number\":\"").append(lotNumber.replace("\"", "\\\"")).append("\",");
            json.append("\"stock_qty_t\":").append(t).append(",");
            json.append("\"stock_qty_kg\":").append(kg).append(",");
            json.append("\"stock_qty_g\":").append(g).append(",");
            json.append("\"stock_qty_mg\":").append(mg);
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