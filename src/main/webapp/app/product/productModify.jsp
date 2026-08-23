<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. PK 파라미터 수신 및 예외 처리
    String productIdStr = request.getParameter("id");
    if (productIdStr == null || productIdStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='productStockList.jsp';</script>");
        return;
    }

    int productId = 0;
    try {
        productId = Integer.parseInt(productIdStr);
    } catch (NumberFormatException e) {
        out.println("<script>alert('유효하지 않은 ID 형식입니다.'); location.href='productStockList.jsp';</script>");
        return;
    }

    // 2. DB 변수 선언
    String category = "PRODUCT";
    String productType = "";
    String itemName = "";

    // 수량 정보 (개수 기준 INT)
    int stockQty = 0;
    int minQty = 0;

    // 3. DB 연결 및 데이터 조회
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

        String sql = "SELECT * FROM products WHERE product_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, productId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            category = rs.getString("category") != null ? rs.getString("category") : "PRODUCT";
            productType = rs.getString("product_type") != null ? rs.getString("product_type") : "";
            itemName = rs.getString("item_name") != null ? rs.getString("item_name") : "";

            // DB 수량 가져오기 (stock_qty, min_qty)
            stockQty = rs.getInt("stock_qty");
            minQty = rs.getInt("min_qty");
        } else {
            out.println("<script>alert('존재하지 않는 데이터입니다.'); location.href='productStockList.jsp';</script>");
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
                    <h5 class="page_tit"><p>재고현황</p><i><img src="/images/svg/location_arrow.svg"></i><b>제품</b><i><img src="/images/svg/location_arrow.svg"></i>수정</h5>
                </div>
                <form action="productModifyAction.jsp" method="post">
                    <input type="hidden" name="productId" value="<%= productId %>">
                    <input type="hidden" name="category" value="<%= category %>">
                    <input type="hidden" name="stock_qty" value="<%= stockQty %>">
                    <section class="radius">
                        <dl class="w25">
                            <dt>종류</dt>
                            <dd>
                                <select class="og_select" name="product_type" required>
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
                            <dd><input type="text" name="item_name" class="inputText" placeholder="제품명 입력" value="<%= itemName %>" required></dd>
                        </dl>
                        <dl class="volume stock w25">
                            <dt>현재 재고개수</dt>
                            <dd>
                                <div class="unit_ea"><input type="text" class="inputText" inputmode="decimal" value="<%= String.format("%,d", stockQty) %>" disabled="disabled"><i>개</i></div>
                            </dd>
                        </dl>
                        <dl class="volume min w25">
                            <dt>최소 재고개수</dt>
                            <dd>
                                <div class="unit_ea"><input type="text" name="min_qty" class="inputText" inputmode="decimal" value="<%= String.format("%,d", minQty) %>"><i>개</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="180" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="180">수정</button>
                        </div>
                    </section>
                </form>
            </div>
        </div>
        <script>
            $(document).ready(function() {
                // 3자리 콤마 포맷팅 함수
                function formatWithComma(str) {
                    if (!str) return '';
                    return str.replace(/,/g, '').replace(/\B(?=(\d{3})+(?!\d))/g, ',');
                }

                // 입력 시 숫자 전용 + 3자리 콤마 포맷팅
                $(document).on('input', 'input[inputmode="decimal"]:not([disabled])', function() {
                    let value = $(this).val();
                    value = value.replace(/[^0-9]/g, '');
                    $(this).val(formatWithComma(value));
                });

                // 폼 제출 전 콤마 제거
                $('form').on('submit', function () {
                    $(this).find('input[inputmode="decimal"]').each(function () {
                        let rawVal = $(this).val().replace(/,/g, '');
                        $(this).val(rawVal);
                    });
                });
            });
        </script>
    </div>
<jsp:include page="/app/include/FooterDocType.jsp" />