<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content registPage totalReg">
                <div class="title_set">
                    <h5 class="page_tit"><p>입고등록</p></h5>
                </div>
                <div class="top_control">
                    <button type="button" class="raw" data-target="raw">원료</button>
                    <button type="button" class="product" data-target="product">제품</button>
                    <button type="button" class="subsidiary" data-target="subsidiary">부자재</button>
                </div>
                <!--원료-->
                <form class="raw" action="receivingRegistAction.jsp" method="post">
                    <input type="hidden" name="category" value="RAW">
                    <section class="radius">
                        <dl>
                            <dt>원료명</dt>
                            <dd><input type="text" id="raw_item_name" name="item_name" class="inputText" placeholder="원료명 입력 (자동완성)"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>Lot번호</dt>
                            <dd><input type="text" name="lot_number" class="inputText" placeholder="Lot 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>입고일</dt>
                            <dd><input type="date" name="receipt_date" class="inputText"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조일</dt>
                            <dd><input type="date" name="manufacture_date" class="inputText"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>EXP</dt>
                            <dd><input type="date" name="expiration_date" class="inputText"></dd>
                        </dl>
                        <dl class="volume stock">
                            <dt>입고물량</dt>
                            <dd>
                                <div class="unit_t"><input type="text" name="in_qty_t" class="inputText" inputmode="decimal"><i>t</i></div>
                                <div class="unit_kg"><input type="text" name="in_qty_kg" class="inputText" inputmode="decimal"><i>kg</i></div>
                                <div class="unit_g"><input type="text" name="in_qty_g" class="inputText" inputmode="decimal"><i>g</i></div>
                                <div class="unit_mg"><input type="text" name="in_qty_mg" class="inputText" inputmode="decimal"><i>mg</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="100" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="100">입고등록</button>
                        </div>
                    </section>
                </form>
                <!--//원료-->
                <!--제품-->
                <form class="product" action="receivingRegistAction.jsp" method="post">
                    <input type="hidden" name="category" value="PRODUCT">
                    <section class="radius">
                        <dl class="w25">
                            <dt>종류</dt>
                            <dd>
                                <select class="og_select" name="product_type">
                                    <option value="">선택</option>
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
                        <dl class="w75">
                            <dt>제품명</dt>
                            <dd><input type="text" id="product_item_name" name="item_name" class="inputText" placeholder="제품명 입력 (자동완성)"></dd>
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
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="100" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="100">입고등록</button>
                        </div>
                    </section>
                </form>
                <!--//제품-->
                <!--부자재-->
                <form class="subsidiary" action="receivingRegistAction.jsp" method="post">
                    <input type="hidden" name="category" value="SUBSIDIARY">
                    <section class="radius">
                        <dl class="w25">
                            <dt>종류</dt>
                            <dd>
                                <select class="og_select" name="subsidiary_type">
                                    <option value="">선택</option>
                                    <option>Label</option>
                                    <option>Bottle</option>
                                    <option>Pump</option>
                                    <option>Cap</option>
                                    <option>Box</option>
                                    <option>기타</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w75">
                            <dt>자재명</dt>
                            <dd><input type="text" id="sub_item_name" name="item_name" class="inputText" placeholder="자재명 입력 (자동완성)"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>재질</dt>
                            <dd>
                                <select class="og_select" name="material_type">
                                    <option value="">선택</option>
                                    <option>종이</option>
                                    <option>플라스틱</option>
                                    <option>유리</option>
                                    <option>기타</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="volume stock w25">
                            <dt>등록개수</dt>
                            <dd>
                                <div class="unit_ea"><input type="text" name="in_qty" class="inputText" inputmode="decimal"><i>개</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="100" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="100">입고등록</button>
                        </div>
                    </section>
                </form>
                <!--//부자재-->
            </div>
        </div>
        <script>
            $(document).ready(function() {
                // Autocomplete 공통 호출 함수
                function setupAutocomplete(elementId, categoryName) {
                    $(elementId).autocomplete({
                        source: function(request, response) {
                            $.ajax({
                                url: "searchItems.jsp",
                                type: "GET",
                                data: {
                                    category: categoryName,
                                    keyword: request.term
                                },
                                dataType: "json",
                                success: function(data) {
                                    response(data); // ["원료A", "원료B", ...] 배열 수신
                                }
                            });
                        },
                        minLength: 1
                    });
                }

                // 각 input에 Autocomplete 적용
                setupAutocomplete("#raw_item_name", "RAW");
                setupAutocomplete("#product_item_name", "PRODUCT");
                setupAutocomplete("#sub_item_name", "SUBSIDIARY");

                // Form Submit 시 천단위 콤마(,) 제거
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