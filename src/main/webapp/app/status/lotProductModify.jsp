<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. PK 파라미터 수신 및 예외 처리 (product_lots 테이블의 lot_id 기준)
    String lotIdStr = request.getParameter("id");
    if (lotIdStr == null || lotIdStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='lotStatusList.jsp';</script>");
        return;
    }

    int lotId = 0;
    try {
        lotId = Integer.parseInt(lotIdStr);
    } catch (NumberFormatException e) {
        out.println("<script>alert('유효하지 않은 ID 형식입니다.'); location.href='lotStatusList.jsp';</script>");
        return;
    }

    // 2. DB 변수 선언
    String productType = "";
    String itemName = "";
    String lotNumber = "";
    String manufactureDate = "";
    String expirationDate = "";
    int stockQty = 0;

    // 3. DB 연결 및 데이터 조회 (product_lots와 products 테이블을 item_name으로 조인하여 product_type 함께 조회)
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

        String sql = "SELECT l.*, p.product_type FROM product_lots l LEFT JOIN products p ON l.item_name = p.item_name WHERE l.lot_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, lotId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            productType = rs.getString("product_type") != null ? rs.getString("product_type") : "";
            itemName = rs.getString("item_name") != null ? rs.getString("item_name") : "";
            lotNumber = rs.getString("lot_number") != null ? rs.getString("lot_number") : "";
            manufactureDate = rs.getString("manufacture_date") != null ? rs.getString("manufacture_date") : "";
            expirationDate = rs.getString("expiration_date") != null ? rs.getString("expiration_date") : "";
            stockQty = rs.getInt("stock_qty");
        } else {
            out.println("<script>alert('존재하지 않는 데이터입니다.'); location.href='lotStatusList.jsp';</script>");
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
                    <h5 class="page_tit"><p>품목관리</p><i><img src="/images/svg/location_arrow.svg"></i><b>완제품 Lot 상세 재고 수정</b></h5>
                </div>
                <form id="modifyForm" action="lotProductModifyAction.jsp" method="post">
                    <input type="hidden" name="lotId" value="<%= lotId %>">
                    <section class="radius">
                        <dl class="w25">
                            <dt>종류</dt>
                            <dd>
                                <select class="og_select" name="product_type" required disabled="disabled">
                                    <option value="">선택</option>
                                    <option value="에센스·세럼·앰플" <%="에센스·세럼·앰플".equals(productType) ? "selected" : "" %>>에센스·세럼·앰플</option>
                                    <option value="샴푸" <%="샴푸".equals(productType) ? "selected" : "" %>>샴푸</option>
                                    <option value="미스트" <%="미스트".equals(productType) ? "selected" : "" %>>미스트</option>
                                    <option value="크림" <%="크림".equals(productType) ? "selected" : "" %>>크림</option>
                                    <option value="토너·스킨" <%="토너·스킨".equals(productType) ? "selected" : "" %>>토너·스킨</option>
                                    <option value="패드(토너패드·패드팩)" <%="패드(토너패드·패드팩)".equals(productType) ? "selected" : "" %>>패드(토너패드·패드팩)</option>
                                    <option value="로션·에멀전" <%="로션·에멀전".equals(productType) ? "selected" : "" %>>로션·에멀전</option>
                                    <option value="아이크림" <%="아이크림".equals(productType) ? "selected" : "" %>>아이크림</option>
                                    <option value="페이스 오일" <%="페이스 오일".equals(productType) ? "selected" : "" %>>페이스 오일</option>
                                    <option value="클렌징 폼" <%="클렌징 폼".equals(productType) ? "selected" : "" %>>클렌징 폼</option>
                                    <option value="클렌징 오일·워터·림" <%="클렌징 오일·워터·림".equals(productType) ? "selected" : "" %>>클렌징 오일·워터·림</option>
                                    <option value="클렌징 티슈" <%="클렌징 티슈".equals(productType) ? "selected" : "" %>>클렌징 티슈</option>
                                    <option value="필링젤·스크럽" <%="필링젤·스크럽".equals(productType) ? "selected" : "" %>>필링젤·스크럽</option>
                                    <option value="선크림" <%="선크림".equals(productType) ? "selected" : "" %>>선크림</option>
                                    <option value="기타" <%="기타".equals(productType) ? "selected" : "" %>>기타</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w50">
                            <dt>제품명</dt>
                            <dd><input type="text" name="item_name" class="inputText" placeholder="제품명 입력" value="<%= itemName %>" required disabled="disabled" required></dd>
                        </dl>
                        <dl class="w25">
                            <dt>Lot 번호</dt>
                            <dd><input type="text" name="lot_number" class="inputText" placeholder="Lot 번호 입력" value="<%= lotNumber %>" required></dd>
                        </dl>
                        <dl class="w50">
                            <dt>제조일</dt>
                            <dd><input type="date" name="manufacture_date" class="inputText" value="<%= manufactureDate %>"></dd>
                        </dl>
                        <dl class="w50">
                            <dt>EXP (만료일)</dt>
                            <dd><input type="date" name="expiration_date" class="inputText" value="<%= expirationDate %>"></dd>
                        </dl>
                        <dl class="volume stock w25">
                            <dt>Lot 현재 재고 개수</dt>
                            <dd>
                                <div class="unit_ea"><input type="text" name="stock_qty" class="inputText" inputmode="decimal" value="<%= String.format("%,d", stockQty) %>"><i>개</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="180" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="180">수정</button>
                            <button type="button" id="deleteBtn" class="Button brdrGray" data-width="180">삭제</button>
                        </div>
                    </section>
                </form>
            </div>
        </div>
        <script>
            $(document).ready(function() {
                function formatWithComma(str) {
                    if (!str) return '';
                    return str.replace(/,/g, '').replace(/\B(?=(\d{3})+(?!\d))/g, ',');
                }

                $(document).on('input', 'input[inputmode="decimal"]:not([disabled])', function() {
                    let value = $(this).val();
                    value = value.replace(/[^0-9]/g, '');
                    $(this).val(formatWithComma(value));
                });

                $('#modifyForm').on('submit', function () {
                    $(this).find('input[inputmode="decimal"]').each(function () {
                        let rawVal = $(this).val().replace(/,/g, '');
                        $(this).val(rawVal);
                    });
                });

                $('#deleteBtn').on('click', function() {
                    if (confirm('정말 삭제하시겠습니까?')) {
                        let form = $('#modifyForm');
                        form.attr('action', 'lotProductDeleteAction.jsp');
                        form.submit();
                    }
                });
            });
        </script>
    </div>
<jsp:include page="/app/include/FooterDocType.jsp" />