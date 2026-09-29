<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:include page="/app/include/HeaderDocType.jsp" />
<div id="wrap">
    <jsp:include page="/app/include/Header.jsp" />
    <div id="container">
        <div class="content workOrderProgressFilling">
            <div class="title_set">
                <h5 class="page_tit">
                    <p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>진행현황</b><i><img src="/images/svg/location_arrow.svg"></i>충진중
                </h5>
            </div>
            <section class="radius">
                <form>
                    <h6 class="doc_tit">포장 지시 및 기록서</h6>
                    <fieldset class="head">
                        <ul>
                            <li>지시일자 : 년 월 일</li>
                            <li>작업일자 : 년 월 일</li>
                        </ul>
                        <table>
                            <tr>
                                <th rowspan="2">결<br>재</th>
                                <th>담당</th>
                                <th>팀장</th>
                            </tr>
                            <tr>
                                <td class="box"><input type="text" placeholder="담당입력"></td>
                                <td class="box"><input type="text" placeholder="담당입력"></td>
                            </tr>
                        </table>
                    </fieldset>
                    <fieldset class="body">
                        <table>
                            <thead>
                                <tr>
                                    <th colspan="4">제품명</th>
                                    <th>제조번호<br>(LOT NO)</th>
                                    <th>지시수량<br>(ea)</th>
                                    <th>제조입고량<br>(kg)</th>
                                </tr>
                                <tr>
                                    <td colspan="4" class="name">제품명(용량mL)</td>
                                    <td class="lot">M26I15<br>EXP290914</td>
                                    <td><div class="unit"><input type="text" class="inputText"><i>ea</i></div></td>
                                    <td><div class="unit"><input type="text" class="inputText"><i>kg</i></div></td>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <th rowspan="2">작업내용</th>
                                    <th rowspan="2">설비명</th>
                                    <th colspan="3">포장재 투입 수량 (ea)</th>
                                    <th rowspan="2">작업자</th>
                                    <th rowspan="2">자재불량(ea)</th>
                                </tr>
                                <tr>
                                    <th colspan="2">포장재 명</th>
                                    <th>수량</th>
                                </tr>
                                <tr>
                                    <td><input type="text" class="inputText" value="충진" placeholder="작업내용 입력"></td>
                                    <td><input type="text" class="inputText" value="충진기" placeholder="설비명 입력"></td>
                                    <td colspan="2"><input type="text" class="inputText" value="포장재명 가져오기" placeholder="포장재명 입력"></td>
                                    <td><div class="unit"><input type="text" class="inputText"><i>ea</i></div></td>
                                    <td><input type="text" class="inputText" value="김정훈" placeholder="작업자 입력"></td>
                                    <td><div class="unit"><input type="text" class="inputText"><i>ea</i></div></td>
                                </tr>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <th rowspan="6">작업 후<br>내부감사</th>
                                    <th rowspan="2" colspan="3">항목</th>
                                    <th colspan="2">확인</th>
                                    <th rowspan="2">비고</th>
                                </tr>
                                <tr>
                                    <th>적합/부적합</th>
                                    <th>부적합(내용)</th>
                                </tr>
                                <tr>
                                    <td colspan="3" class="item">작업이 끝난 완제품의 인수인계 여부</td>
                                    <td>
                                        <div class="radioGroup">
                                            <label class="radioButton"><input type="radio" name="item1" checked><i class="icon"></i><span>적합</span></label>
                                            <label class="radioButton"><input type="radio" name="item1"><i class="icon"></i><span>부적합</span></label>
                                        </div>
                                    </td>
                                    <td><input type="text" class="inputText" disabled="disabled" placeholder="내용입력"></td>
                                    <td><input type="text" class="inputText" placeholder="비고입력"></td>
                                </tr>
                                <tr>
                                    <td colspan="3" class="item">부적합 제품의 별도 보관 여부</td>
                                    <td>
                                        <div class="radioGroup">
                                            <label class="radioButton"><input type="radio" name="item2" checked><i class="icon"></i><span>적합</span></label>
                                            <label class="radioButton"><input type="radio" name="item2"><i class="icon"></i><span>부적합</span></label>
                                        </div>
                                    </td>
                                    <td><input type="text" class="inputText" disabled="disabled" placeholder="내용입력"></td>
                                    <td><input type="text" class="inputText" placeholder="비고입력"></td>
                                </tr>
                                <tr>
                                    <td colspan="3" class="item">사용된 부자재의 제품 사양과의 일치 여부</td>
                                    <td>
                                        <div class="radioGroup">
                                            <label class="radioButton"><input type="radio" name="item3" checked><i class="icon"></i><span>적합</span></label>
                                            <label class="radioButton"><input type="radio" name="item3"><i class="icon"></i><span>부적합</span></label>
                                        </div>
                                    </td>
                                    <td><input type="text" class="inputText" disabled="disabled" placeholder="내용입력"></td>
                                    <td><input type="text" class="inputText" placeholder="비고입력"></td>
                                </tr>
                                <tr>
                                    <td colspan="3" class="item">지시 수량과 생산수량의 일치 여부</td>
                                    <td>
                                        <div class="radioGroup">
                                            <label class="radioButton"><input type="radio" name="item4" checked><i class="icon"></i><span>적합</span></label>
                                            <label class="radioButton"><input type="radio" name="item4"><i class="icon"></i><span>부적합</span></label>
                                        </div>
                                    </td>
                                    <td><input type="text" class="inputText" disabled="disabled" placeholder="내용입력"></td>
                                    <td><input type="text" class="inputText" placeholder="비고입력"></td>
                                </tr>
                                <tr>
                                    <th rowspan="6">생산현황</th>
                                    <th>작업 시간</th>
                                    <td><div class="unit"><input type="text" class="inputText"><i>hr</i></div></td>
                                    <th rowspan="6">수율분석</th>
                                    <th>제조량</th>
                                    <td colspan="2"><div class="unit"><input type="text" class="inputText"><i>kg</i></div></td>
                                </tr>
                                <tr>
                                    <th>작업 인원</th>
                                    <td><div class="unit"><input type="text" class="inputText"><i>명</i></div></td>
                                    <th>생산량</th>
                                    <td colspan="2"><div class="unit"><input type="text" class="inputText"><i>kg</i></div></td>
                                </tr>
                                <tr>
                                    <th>지시 수량</th>
                                    <td><div class="unit"><input type="text" class="inputText"><i>ea</i></div></td>
                                    <th rowspan="2">수율</th>
                                    <td colspan="2" rowspan="2">
                                        <div class="unit"><input type="text" class="inputText"><i>%</i></div>
                                        <p class="ex">(생산량/제조량*100)</p>
                                    </td>
                                </tr>
                                <tr>
                                    <th>생산 수량</th>
                                    <td><div class="unit"><input type="text" class="inputText"><i>ea</i></div></td>
                                </tr>
                                <tr>
                                    <th>폐기 수량</th>
                                    <td><div class="unit"><input type="text" class="inputText"><i>ea</i></div></td>
                                    <th rowspan="2">불량율</th>
                                    <td colspan="2" rowspan="2">
                                        <div class="unit"><input type="text" class="inputText"><i>%</i></div>
                                        <p class="ex">(폐기수량/생산수량*100)</p>
                                    </td>
                                </tr>
                                <tr>
                                    <th>출고 수량</th>
                                    <td><div class="unit"><input type="text" class="inputText"><i>ea</i></div></td>
                                </tr>
                                <tr class="last">
                                    <th>작성자</th>
                                    <td colspan="2"><input type="text" class="inputText" placeholder="작성자 입력"></td>
                                    <th colspan="2">판정</th>
                                    <td colspan="2">
                                        <div class="radioGroup">
                                            <label class="radioButton"><input type="radio" name="verdict" checked><i class="icon"></i><span>적합</span></label>
                                            <label class="radioButton"><input type="radio" name="verdict"><i class="icon"></i><span>부적합</span></label>
                                        </div>
                                    </td>
                                </tr>
                            </tfoot>
                        </table>
                    </fieldset>
                </form>
                <div class="bottom_btns">
                    <button type="button" class="Button bgGray" data-width="180" onclick="location.href='../workOrderProgressList.jsp';">목록</button>
                    <button type="submit" id="btnComplete" class="Button bgBlue" data-width="180">충진완료</button>
                </div>
            </section>
        </div>
    </div>
</div>
<jsp:include page="/app/include/FooterDocType.jsp" />
