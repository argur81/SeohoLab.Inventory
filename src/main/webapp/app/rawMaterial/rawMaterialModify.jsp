<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. PK 파라미터 수신 및 예외 처리
    String itemIdStr = request.getParameter("id");
    if (itemIdStr == null || itemIdStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='rawMaterialStockList.jsp';</script>");
        return;
    }

    int itemId = 0;
    try {
        itemId = Integer.parseInt(itemIdStr);
    } catch (NumberFormatException e) {
        out.println("<script>alert('유효하지 않은 ID 형식입니다.'); location.href='rawMaterialStockList.jsp';</script>");
        return;
    }

    // 2. DB 데이터를 담을 변수 선언 및 초기화
    String category = "";
    String itemName = "";
    String workOrder1 = "", workOrder2 = "", workOrder3 = "";
    String lotNumber = "";
    String receiptDate = "", manufactureDate = "", expirationDate = "";

    // DB에 자동 변환되어 저장되어 있는 단위별 수치들
    double inQtyT = 0, inQtyKg = 0, inQtyG = 0, inQtyMg = 0;
    double minQtyT = 0, minQtyKg = 0, minQtyG = 0, minQtyMg = 0;

    // 3. Cloudtype MariaDB 접속 설정
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

        String sql = "SELECT * FROM items WHERE item_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, itemId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            category = rs.getString("category") != null ? rs.getString("category") : "RAW";
            itemName = rs.getString("item_name") != null ? rs.getString("item_name") : "";
            
            workOrder1 = rs.getString("work_order_1") != null ? rs.getString("work_order_1") : "";
            workOrder2 = rs.getString("work_order_2") != null ? rs.getString("work_order_2") : "";
            workOrder3 = rs.getString("work_order_3") != null ? rs.getString("work_order_3") : "";
            
            lotNumber = rs.getString("lot_number") != null ? rs.getString("lot_number") : "";
            
            receiptDate = rs.getString("receipt_date") != null ? rs.getString("receipt_date") : "";
            // DB의 actual 컬럼명 (manufacture_dat)
            manufactureDate = rs.getString("manufacture_date") != null ? rs.getString("manufacture_date") : "";
            expirationDate = rs.getString("expiration_date") != null ? rs.getString("expiration_date") : "";

            // DB에 저장된 단위별 변환 수치 조회
            inQtyT = rs.getDouble("in_qty_t");
            inQtyKg = rs.getDouble("in_qty_kg");
            inQtyG = rs.getDouble("in_qty_g");
            inQtyMg = rs.getDouble("in_qty_mg");

            minQtyT = rs.getDouble("min_qty_t");
            minQtyKg = rs.getDouble("min_qty_kg");
            minQtyG = rs.getDouble("min_qty_g");
            minQtyMg = rs.getDouble("min_qty_mg");
        } else {
            out.println("<script>alert('존재하지 않는 데이터입니다.'); location.href='rawMaterialStockList.jsp';</script>");
            return;
        }
    } catch (Exception e) {
        out.println("<!-- DB Error: " + e.getMessage() + " -->");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content registPage">
                <div class="title_set">
                    <h5 class="page_tit"><p>원료</p><i><img src="/images/svg/location_arrow.svg"></i><%= itemName %></h5>
                </div>
                <form action="rawMaterialModifyAction.jsp" method="post">
                    <input type="hidden" name="itemId" value="<%= itemId %>">
                    <input type="hidden" name="category" value="<%= category %>">
                    <section class="radius">
                        <dl class="w25">
                            <dt>원료명</dt>
                            <dd><input type="text" name="item_name" class="inputText" placeholder="원료명 입력" value="<%= itemName %>" required></dd>
                        </dl>
                        <dl class="w25">
                            <dt>작업 지시서명1</dt>
                            <dd><input type="text" name="work_order_1" class="inputText" placeholder="작업 지시서명1 입력" value="<%= workOrder1 %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>작업 지시서명2</dt>
                            <dd><input type="text" name="work_order_2" class="inputText" placeholder="작업 지시서명2 입력" value="<%= workOrder2 %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>작업 지시서명3</dt>
                            <dd><input type="text" name="work_order_3" class="inputText" placeholder="작업 지시서명3 입력" value="<%= workOrder3 %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>Lot번호</dt>
                            <dd><input type="text" name="lot_number" class="inputText" placeholder="Lot 입력" value="<%= lotNumber %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>입고일</dt>
                            <dd><input type="date" name="receipt_date" class="inputText" value="<%= receiptDate %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조일</dt>
                            <dd><input type="date" name="manufacture_date" class="inputText" value="<%= manufactureDate %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>만료일</dt>
                            <dd><input type="date" name="expiration_date" class="inputText" value="<%= expirationDate %>"></dd>
                        </dl>
                        <dl class="volume stock">
                            <dt>입고물량</dt>
                            <dd>
                                <div class="unit_t"><input type="text" name="in_qty_t" class="inputText" inputmode="decimal" value="<%= inQtyT %>"><i>t</i></div>
                                <div class="unit_kg"><input type="text" name="in_qty_kg" class="inputText" inputmode="decimal" value="<%= inQtyKg %>"><i>kg</i></div>
                                <div class="unit_g"><input type="text" name="in_qty_g" class="inputText" inputmode="decimal" value="<%= inQtyG %>"><i>g</i></div>
                                <div class="unit_mg"><input type="text" name="in_qty_mg" class="inputText" inputmode="decimal" value="<%= inQtyMg %>"><i>mg</i></div>
                            </dd>
                        </dl>
                        <dl class="volume min">
                            <dt>최소 재고물량</dt>
                            <dd>
                                <div class="unit_t"><input type="text" name="min_qty_t" class="inputText" inputmode="decimal" value="<%= minQtyT %>"><i>t</i></div>
                                <div class="unit_kg"><input type="text" name="min_qty_kg" class="inputText" inputmode="decimal" value="<%= minQtyKg %>"><i>kg</i></div>
                                <div class="unit_g"><input type="text" name="min_qty_g" class="inputText" inputmode="decimal" value="<%= minQtyG %>"><i>g</i></div>
                                <div class="unit_mg"><input type="text" name="min_qty_mg" class="inputText" inputmode="decimal" value="<%= minQtyMg %>"><i>mg</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="100" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="100">수정</button>
                        </div>
                    </section>
                </form>
            </div>
        </div>
        <script>
            $('form').on('submit', function () {
                $(this).find('input[inputmode="decimal"]').each(function () {
                    let rawVal = $(this).val().replace(/,/g, '');
                    $(this).val(rawVal);
                });
            });
        </script>
    </div>
<jsp:include page="/app/include/FooterDocType.jsp" />