<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content registPage">
                <div class="title_set">
                    <h5 class="page_tit"><p>신규등록</p><i><img src="/images/svg/location_arrow.svg"></i><b>제품</b></h5>
                </div>
                <form id="regForm" action="productRegistAction.jsp" method="post">
                    <section class="radius">
                        <dl class="w25">
                            <dt>종류</dt>
                            <dd>
                                <select class="og_select" name="product_type" required>
                                    <option value="">선택</option>
                                    <option value="에센스·세럼·앰플">에센스·세럼·앰플</option>
                                    <option value="샴푸">샴푸</option>
                                    <option value="미스트">미스트</option>
                                    <option value="크림">크림</option>
                                    <option value="토너·스킨">토너·스킨</option>
                                    <option value="패드(토너패드·패드팩)">패드(토너패드·패드팩)</option>
                                    <option value="로션·에멀전">로션·에멀전</option>
                                    <option value="아이크림">아이크림</option>
                                    <option value="페이스 오일">페이스 오일</option>
                                    <option value="클렌징 폼">클렌징 폼</option>
                                    <option value="클렌징 오일·워터·림">클렌징 오일·워터·림</option>
                                    <option value="클렌징 티슈">클렌징 티슈</option>
                                    <option value="필링젤·스크럽">필링젤·스크럽</option>
                                    <option value="선크림">선크림</option>
                                    <option value="기타">기타</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w50">
                            <dt>제품명</dt>
                            <dd><input type="text" name="item_name" class="inputText" placeholder="제품명 입력" required></dd>
                        </dl>
                        <dl class="volume min w25">
                            <dt>최소 재고개수</dt>
                            <dd>
                                <div class="unit_ea"><input type="text" name="min_qty" class="inputText" inputmode="decimal" placeholder="0"><i>개</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="180" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="180">등록</button>
                        </div>
                    </section>
                </form>
            </div>
        </div>
        <script>
            $(document).ready(function() {
                // 정수/숫자 3자리 콤마 포맷팅
                function formatWithComma(str) {
                    if (!str) return '';
                    return str.replace(/,/g, '').replace(/\B(?=(\d{3})+(?!\d))/g, ',');
                }

                // 입력 시 숫자 전용 + 콤마 포맷팅
                $(document).on('input', 'input[inputmode="decimal"]', function() {
                    let value = $(this).val();
                    value = value.replace(/[^0-9]/g, ''); // 완제품 개수는 정수 처리
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