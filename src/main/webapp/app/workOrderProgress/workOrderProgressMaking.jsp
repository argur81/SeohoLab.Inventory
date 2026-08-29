<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:include page="/app/include/HeaderDocType.jsp" />
<div id="wrap">
    <jsp:include page="/app/include/Header.jsp" />
    <div id="container">
        <div class="content workOrderProgressDetail">
            <div class="title_set">
                <h5 class="page_tit">
                    <p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>진행현황</b><i><img src="/images/svg/location_arrow.svg"></i>제조시작</b>
                </h5>
            </div>
            <section class="radius">
                <div class="road_data">
                    <table>
                        <colgroup>
                            <col width="100">
                            <col width="45">
                            <col width="240">
                            <col width="130">
                            <col width="130">
                            <col width="130">
                            <col width="130">
                            <col width="200">
                            <col width="130">
                            <col width="130">
                        </colgroup>
                        <thead>
                            <tr>
                                <th colspan="7" rowspan="3" class="doc_name">제조 지시 및 공정 기록서</th>
                                <th>작성</th>
                                <th>검토</th>
                                <th>승인</th>
                            </tr>
                            <tr>
                                <td class="sign">&nbsp;</td>
                                <td class="sign">&nbsp;</td>
                                <td class="sign">&nbsp;</td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <th>제품명</th>
                                <td colspan="5">제품명가져오가</td>
                                <th colspan="2">제조지시량</th>
                                <td colspan="2">제조지시량 가져오기</td>
                            </tr>
                            <tr>
                                <th>제조번호</th>
                                <td colspan="2"><input type="text" class="inputText"></td>
                                <td colspan="3">
                                    <div class="yy-mm-dd"><input type="date" class="inputText"><span>까지</span></div>
                                </td>
                                <th>제조지시자</th>
                                <td>제조지시자 가져오기</td>
                                <th>제조자</th>
                                <td><input type="texts" class="inputText" value="윤철우"></td>
                            </tr>
                            <tr>
                                <th>제조기기</th>
                                <td colspan="5">제조기기 가져오기</td>
                                <th>제조지시일</th>
                                <td>제조지시일 가져오기</td>
                                <th>제조일자</th>
                                <td><input type="date" class="inputText"></td>
                            </tr>
                            <tr>
                                <th>상</th>
                                <th>No.</th>
                                <th>원료명</th>
                                <th>Lot</th>
                                <th>함량(%)</th>
                                <th>제조지시량(kg)</th>
                                <th>제조지시량(g)</th>
                                <th>투입량</th>
                                <th>제조방법</th>
                                <th>비고</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="al-center">A상</td>
                                <td class="al-center">1</td>
                                <td>원료명 가져오기</td>
                                <td><input type="text" class="inputText"></td>
                                <td class="al-right">함량(%) 가져오기</td>
                                <td class="al-right">제조지시량(kg)</td>
                                <td class="al-right">제조지시량(kg)</td>
                                <td>
                                    <div class="input_enter">
                                        <input type="texts" class="inputText">
                                        <select class="og_select">
                                            <option>kg</option>
                                            <option>g</option>
                                        </select>
                                    </div>
                                </td>
                                <td>제조방법 가져오기</td>
                                <td>비고 가져오기</td>
                            </tr>
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="4">합계</th>
                                <td id="load-total-pct" class="al-right">합계 함량(%) 가져오기</td>
                                <td id="load-total-kg" class="al-right">합계 kg 가져오기</td>
                                <td id="load-total-g" class="al-right">합계 g가져오기</td>
                                <td colspan="3">&nbsp;</td>
                            </tr>
                            <tr>
                                <th>항목</th>
                                <th colspan="2">기준</th>
                                <th colspan="3">결과</th>
                                <th colspan="2">이론제조량</th>
                                <td colspan="2"><span id="load-theor-qty"></span> <span id="load-theor-unit"></span></td>
                            </tr>
                            <tr>
                                <th>성상</th>
                                <td colspan="2" id="load-appearance">성상 가져오기</td>
                                <td colspan="3"><input type="texts" class="inputText"></td>
                                <th colspan="2">실제제조량</th>
                                <td colspan="2">합계에 있는 투립량 합계 kg기준</td>
                            </tr>
                            <tr>
                                <th>향취</th>
                                <td colspan="2" id="load-scent">향취가져오기</td>
                                <td colspan="3"><input type="texts" class="inputText"></td>
                                <th colspan="2">제조수율</th>
                                <td colspan="2"><input type="texts" class="inputText"></td>
                            </tr>
                            <tr>
                                <th>비중</th>
                                <td colspan="2" id="load-specific-gravity">비중 가져오기</td>
                                <td colspan="3"><input type="texts" class="inputText"></td>
                                <th colspan="2">제조수율기준</th>
                                <td colspan="2" id="load-yield-standard">제조수율기준</td>
                            </tr>
                            <tr>
                                <th>ph</th>
                                <td colspan="2" id="load-ph">ph 가져오기</td>
                                <td colspan="3"><input type="texts" class="inputText"></td>
                                <td colspan="4" class="al-center">제조수율 = (실제제조량/이론제조량) * 100</td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                <div class="bottom_btns">
                    <button type="button" id="backListBtn" class="Button bgGray" data-width="180">목록</button>
                    <button type="button" id="completedProgressBtn" class="Button bgBlue" data-width="180">제조완료</button>
                    <button type="button" id="deleteBtn" class="Button brdrGray" data-width="180">삭제</button>
                    <button type="button" id="printBtn" class="Button brdrGreen" data-width="180">인쇄</button>
                </div>
            </section>
        </div>
    </div>
</div>
<jsp:include page="/app/include/FooterDocType.jsp" />