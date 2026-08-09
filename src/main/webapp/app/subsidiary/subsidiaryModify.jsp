<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // PK 수신 (subsidiary_id 또는 id)
    String idStr = request.getParameter("subsidiary_id");
    if (idStr == null || idStr.trim().isEmpty()) {
        idStr = request.getParameter("id");
    }

    int subsidiaryId = 0;
    try {
        if (idStr != null) subsidiaryId = Integer.parseInt(idStr.trim());
    } catch (NumberFormatException e) {
        subsidiaryId = 0;
    }

    if (subsidiaryId <= 0) {
        out.println("<script>alert('잘못된 접근입니다. (아이디 누락)'); history.back();</script>");
        return;
    }

    // DB 접속 정보
    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    // 변수 초기화
    String category = "SUBSIDIARY";
    String subsidiaryType = "";
    String itemName = "";
    String materialType = "";
    int inQty = 0;
    int stockQty = 0;
    int minQty = 0;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        String sql = "SELECT * FROM subsidiary WHERE subsidiary_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, subsidiaryId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            category = rs.getString("category");
            subsidiaryType = rs.getString("subsidiary_type") != null ? rs.getString("subsidiary_type") : "";
            itemName = rs.getString("item_name") != null ? rs.getString("item_name") : "";
            materialType = rs.getString("material_type") != null ? rs.getString("material_type") : "";
            inQty = rs.getInt("in_qty");
            stockQty = rs.getInt("stock_qty");
            minQty = rs.getInt("min_qty");
        } else {
            out.println("<script>alert('존재하지 않는 부자재 데이터입니다.'); history.back();</script>");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content registPage">
                <div class="title_set">
                    <h5 class="page_tit"><p>부자재</p><i><img src="/images/svg/location_arrow.svg"></i><b>재고현황</b><i><img src="/images/svg/location_arrow.svg"></i>수정</h5>
                </div>
                <form action="subsidiaryModifyAction.jsp" method="post">
                    <input type="hidden" name="subsidiary_id" value="<%= subsidiaryId %>">
                    <input type="hidden" name="id" value="<%= subsidiaryId %>">
                    <input type="hidden" name="category" value="<%= category %>">
                    <input type="hidden" name="stock_qty" value="<%= stockQty %>">
                    <section class="radius">
                        <dl class="w25">
                            <dt>종류</dt>
                            <dd>
                                <select class="og_select" name="subsidiary_type">
                                    <option value="">선택</option>
                                    <option value="Label" <%="Label" .equalsIgnoreCase(subsidiaryType) ? "selected" : "" %>>Label</option>
                                    <option value="Bottle" <%="Bottle" .equalsIgnoreCase(subsidiaryType) ? "selected" : "" %>>Bottle</option>
                                    <option value="Pump" <%="Pump" .equalsIgnoreCase(subsidiaryType) ? "selected" : "" %>>Pump</option>
                                    <option value="Cap" <%="Cap" .equalsIgnoreCase(subsidiaryType) ? "selected" : "" %>>Cap</option>
                                    <option value="Box" <%="Box" .equalsIgnoreCase(subsidiaryType) ? "selected" : "" %>>Box</option>
                                    <option value="기타" <%="기타" .equalsIgnoreCase(subsidiaryType) ? "selected" : "" %>>기타</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w50">
                            <dt>제품명</dt>
                            <dd><input type="text" name="item_name" class="inputText" placeholder="제품명 입력" value="<%= itemName %>" required></dd>
                        </dl>
                        <dl class="w25">
                            <dt>재질</dt>
                            <dd>
                                <select class="og_select" name="material_type">
                                    <option value="">선택</option>
                                    <option value="종이" <%="종이" .equalsIgnoreCase(materialType) ? "selected" : "" %>>종이</option>
                                    <option value="플라스틱" <%="플라스틱" .equalsIgnoreCase(materialType) ? "selected" : "" %>>플라스틱</option>
                                    <option value="유리" <%="유리" .equalsIgnoreCase(materialType) ? "selected" : "" %>>유리</option>
                                    <option value="기타" <%="기타" .equalsIgnoreCase(materialType) ? "selected" : "" %>>기타</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="volume stock w25">
                            <dt>현재 재고개수</dt>
                            <dd>
                                <div class="unit_ea"><input type="text" name="in_qty" class="inputText" inputmode="decimal" value="<%= stockQty %>" disabled="disabled"><i>개</i></div>
                            </dd>
                        </dl>
                        <dl class="volume min w25">
                            <dt>최소 재고개수</dt>
                            <dd>
                                <div class="unit_ea"><input type="text" name="min_qty" class="inputText" inputmode="decimal" value="<%= minQty %>"><i>개</i></div>
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