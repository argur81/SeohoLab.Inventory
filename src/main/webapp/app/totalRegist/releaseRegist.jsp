<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content registPage totalReg">
                <div class="title_set">
                    <h5 class="page_tit"><p>출고등록</p></h5>
                </div>
                <div class="top_control">
                    <button type="button" class="raw" data-target="raw">원료</button>
                    <button type="button" class="product" data-target="product">제품</button>
                </div>
                <!--원료-->
                <form class="raw" action="releaseRegistAction.jsp" method="post">
                    <input type="hidden" name="category" value="RAW">
                    <section class="radius">
                        <dl>
                            <dt>원료명</dt>
                            <dd><input type="text" id="raw_item_name" name="item_name" class="inputText" placeholder="원료명 입력 (자동완성)"></dd>
                        </dl>
                        <dl class="volume stock">
                            <dt>출고량</dt>
                            <dd>
                                <div class="unit_t"><input type="text" name="out_qty_t" class="inputText" inputmode="decimal"><i>t</i></div>
                                <div class="unit_kg"><input type="text" name="out_qty_kg" class="inputText" inputmode="decimal"><i>kg</i></div>
                                <div class="unit_g"><input type="text" name="out_qty_g" class="inputText" inputmode="decimal"><i>g</i></div>
                                <div class="unit_mg"><input type="text" name="out_qty_mg" class="inputText" inputmode="decimal"><i>mg</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="100" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="100">출고등록</button>
                        </div>
                    </section>
                </form>
                <!--//원료-->
                <!--제품-->
                <form class="product" action="releaseRegistAction.jsp" method="post">
                    <input type="hidden" name="category" value="PRODUCT">
                    <section class="radius">
                        <dl class="w75">
                            <dt>제품명</dt>
                            <dd><input type="text" id="product_item_name" name="item_name" class="inputText" placeholder="제품명 입력 (자동완성)"></dd>
                        </dl>
                        <dl class="volume stock w25">
                            <dt>출고개수</dt>
                            <dd>
                                <div class="unit_ea"><input type="text" name="out_qty" class="inputText" inputmode="decimal"><i>개</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="100" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="100">출고등록</button>
                        </div>
                    </section>
                </form>
                <!--//제품-->
            </div>
        </div>
        
        <script>
            $(document).ready(function() {
                // Autocomplete 설정 (기존 searchItems.jsp 공용 사용)
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
                                    response(data);
                                }
                            });
                        },
                        minLength: 1,
                        appendTo: "body"
                    });
                }

                setupAutocomplete("#raw_item_name", "RAW");
                setupAutocomplete("#product_item_name", "PRODUCT");

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