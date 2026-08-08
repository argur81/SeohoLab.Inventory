<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content registPage">
                <div class="title_set">
                    <h5 class="page_tit"><p>원료</p><i><img src="/images/svg/location_arrow.svg"></i>신규등록</h5>
                </div>
                <form id="regForm" action="rawMaterialRegistAction.jsp" method="post">
                    <input type="hidden" name="category" value="RAW">
                    <section class="radius">
                        <dl class="w25">
                            <dt>원료명</dt>
                            <dd><input type="text" name="item_name" class="inputText" placeholder="원료명 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>작업 지시서명1</dt>
                            <dd><input type="text" name="work_order_1" class="inputText" placeholder="작업 지시서명1 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>작업 지시서명2</dt>
                            <dd><input type="text" name="work_order_2" class="inputText" placeholder="작업 지시서명2 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>작업 지시서명3</dt>
                            <dd><input type="text" name="work_order_3" class="inputText" placeholder="작업 지시서명3 입력"></dd>
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
                            <dt>만료일</dt>
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
                        <dl class="volume min">
                            <dt>최소 재고물량</dt>
                            <dd>
                                <div class="unit_t"><input type="text" name="min_qty_t" class="inputText" inputmode="decimal"><i>t</i></div>
                                <div class="unit_kg"><input type="text" name="min_qty_kg" class="inputText" inputmode="decimal"><i>kg</i></div>
                                <div class="unit_g"><input type="text" name="min_qty_g" class="inputText" inputmode="decimal"><i>g</i></div>
                                <div class="unit_mg"><input type="text" name="min_qty_mg" class="inputText" inputmode="decimal"><i>mg</i></div>
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