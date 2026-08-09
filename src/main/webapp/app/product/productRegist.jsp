<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content registPage">
                <div class="title_set">
                    <h5 class="page_tit"><p>제품</p><i><img src="/images/svg/location_arrow.svg"></i>신규등록</h5>
                </div>
                <form id="regForm" action="productRegistAction.jsp" method="post">
                    <section class="radius">
                        <dl class="w25">
                            <dt>종류</dt>
                            <dd>
                                <select class="og_select" name="product_type">
                                    <option>선택</option>
                                    <option>에센스·세럼·앰플</option>
                                    <option>샴푸</option>
                                    <option>미스트</option>
                                    <option>크림</option>
                                    <option>토너·스킨</option>
                                    <option>패드(토너패드·패드팩)</option>
                                    <option>로션·에멀전</option>
                                    <option>아이크림</option>
                                    <option>페이스 오일</option>
                                    <option>클렌징 폼</option>
                                    <option>클렌징 오일·워터·림</option>
                                    <option>클렌징 티슈</option>
                                    <option>필링젤·스크럽</option>
                                    <option>선크림</option>
                                    <option>기타</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w50">
                            <dt>제품명</dt>
                            <dd><input type="text" name="item_name" class="inputText" placeholder="제품명 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>Lot번호</dt>
                            <dd><input type="text" name="lot_number" class="inputText" placeholder="Lot 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조일</dt>
                            <dd><input type="date" name="manufacture_date" class="inputText"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>EXP</dt>
                            <dd><input type="date" name="expiration_date" class="inputText"></dd>
                        </dl>
                        <dl class="volume stock w25">
                            <dt>등록개수</dt>
                            <dd>
                                <div class="unit_ea"><input type="text" name="in_qty" class="inputText" inputmode="decimal"><i>개</i></div>
                            </dd>
                        </dl>
                        <dl class="volume min w25">
                            <dt>최소 재고개수</dt>
                            <dd>
                                <div class="unit_ea"><input type="text" name="min_qty" class="inputText" inputmode="decimal"><i>개</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="100" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="100">등록</button>
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