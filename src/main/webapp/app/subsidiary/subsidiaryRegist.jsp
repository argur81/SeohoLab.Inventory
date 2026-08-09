<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content registPage">
                <div class="title_set">
                    <h5 class="page_tit"><p>부자재</p><i><img src="/images/svg/location_arrow.svg"></i><b>신규등록</b></h5>
                </div>
                <form id="regForm" action="subsidiaryRegistAction.jsp" method="post">
                    <section class="radius">
                        <dl class="w25">
                            <dt>종류</dt>
                            <dd>
                                <select class="og_select" name="subsidiary_type">
                                    <option>선택</option>
                                    <option>Label</option>
                                    <option>Bottle</option>
                                    <option>Pump</option>
                                    <option>Cap</option>
                                    <option>Box</option>
                                    <option>기타</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w50">
                            <dt>자재명</dt>
                            <dd><input type="text" name="item_name" class="inputText" placeholder="제품명 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>재질</dt>
                            <dd>
                                <select class="og_select" name="material_type">
                                    <option>선택</option>
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