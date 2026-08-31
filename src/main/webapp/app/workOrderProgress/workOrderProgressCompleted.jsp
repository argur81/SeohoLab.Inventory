<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:include page="/app/include/HeaderDocType.jsp" />
<div id="wrap">
    <jsp:include page="/app/include/Header.jsp" />
    <div id="container">
        <div class="content workOrderProgressDetail">
            <div class="title_set">
                <h5 class="page_tit">
                    <p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>진행현황</b><i><img src="/images/svg/location_arrow.svg"></i>충진중
                </h5>
            </div>
            <section class="radius subsidiary_reg">
                <dl class="w25">
                    <dt>Lot</dt>
                    <dd>
                        <input type="text" class="inputText" value="로트번호 가져오기" disabled>
                    </dd>
                </dl>
                <dl class="w50">
                    <dt>제품명</dt>
                    <dd><input type="text" class="inputText" value="제품명 가져오기" disabled></dd>
                </dl>
                <dl>
                    <dt>제조지시량</dt>
                    <dd>제조지시량 가져오기</dd>
                </dl>
                <h5 class="in_tit">부자재 등록</h5>
                <div class="row">
                    <dl class="w50">
                        <dt>부자재명</dt>
                        <dd><input type="text" class="inputText" placeholder="자동완성"></dd>
                    </dl>
                    <dl class="w25">
                        <dt>종류</dt>
                        <dd>
                            <select class="og_select" id="sub_subsidiary_type" disabled>
                                <option value="">선택</option>
                                <option value="Label">Label</option>
                                <option value="Bottle">Bottle</option>
                                <option value="Pump">Pump</option>
                                <option value="Cap">Cap</option>
                                <option value="Box">Box</option>
                                <option value="기타">기타</option>
                            </select>
                        </dd>
                    </dl>
                    <dl class="volume stock w25">
                        <dt>사용개수</dt>
                        <dd>
                            <div class="unit_ea"><input type="text" name="out_qty" class="inputText" inputmode="decimal"><i>개</i></div>
                        </dd>
                    </dl>
                </div>
                <div class="add_btn">
                    <button type="button" id="addExtraRowBtn" class="Button">부자재 추가</button>
                </div>
                <div class="bottom_btns">
                    <button type="button" class="Button bgGray" data-width="180">목록</button>
                    <button type="button" class="Button bgBlue" data-width="180">충진시작</button>
                    <button type="button" class="Button brdrGray" data-width="180">삭제</button>
                </div>
            </section>
        </div>
    </div>
</div>
<jsp:include page="/app/include/FooterDocType.jsp" />