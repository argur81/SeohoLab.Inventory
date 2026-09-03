<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.LocalDate" %>
<%
    // 오늘 날짜 계산 (YYYY-MM-DD)
    String todayDate = LocalDate.now().toString();
%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <div id="container" class="workOrderRequest">
            <div class="content">
                <div class="top_btn">
                        <button class="back" title="돌아가기" onclick="history.back();"><img src="/images/svg/arrow-left-solid-full.svg"></button>
                        <button class="home" title="홈으로" onclick="location.href='/app/home/main.jsp';"><img src="/images/svg/house-regular-full.svg"></button>
                        <button class="back" title="리셋" onclick="location.reload();"><img src="/images/svg/rotate-solid-full.svg"></button>
                </div>
                <!--Step1-->
                <div class="step1" id="step1Area">
                    <div class="search_wrap">
                        <div class="search_form">
                            <i><img src="/images/logo/symbol.svg"></i>
                            <input type="text" id="searchProductName" placeholder="제품명을 입력하여 검색하세요.">
                        </div>
                    </div>
                </div>
                <!--//Step1-->
                <!--Step2-->
                <div class="step2" id="step2Area" style="display: none;">
                    <div class="road_data">
                        <table class="requestTable">
                            <colgroup>
                                <col width="100">
                                <col width="60">
                                <col width="auto">
                                <col width="120">
                                <col width="120">
                                <col width="120">
                                <col width="120">
                                <col width="110">
                                <col width="110">
                                <col width="110">
                                <col width="110">
                            </colgroup>
                            <thead>
                                <tr>
                                    <th>제품명</th>
                                    <td colspan="5" id="load-product-name"></td>
                                    <th colspan="3">제조지시량</th>
                                    <td colspan="2"><span id="load-target-qty"></span> <span id="load-target-unit"></span></td>
                                </tr>
                                <tr>
                                    <th>제조기기</th>
                                    <td colspan="5" id="load-machine"></td>
                                    <th>제조지시자</th>
                                    <td id="load-manager-name"></td>
                                    <th>제조지시일</th>
                                    <td colspan="2"><%= todayDate %></td>
                                </tr>
                                <tr>
                                    <th>상</th>
                                    <th>No.</th>
                                    <th>원료명</th>
                                    <th>원료시험번호</th>
                                    <th>함량(%)</th>
                                    <th>제조지시량(kg)</th>
                                    <th>제조지시량(g)</th>
                                    <th colspan="2">제조방법</th>
                                    <th colspan="2">비고</th>
                                </tr>
                            </thead>
                            <tbody id="load-items-tbody">
                                <!-- AJAX를 통해 동적 행 및 rowspan이 적용된 Phase가 삽입됩니다 -->
                            </tbody>
                            <tfoot>
                                <tr>
                                    <th colspan="4">합계</th>
                                    <td id="load-total-pct" class="al-right"></td>
                                    <td id="load-total-kg" class="al-right"></td>
                                    <td id="load-total-g" class="al-right"></td>
                                    <td id="load-total-g" class="al-right"></td>
                                    <td colspan="3">&nbsp;</td>
                                </tr>
                                <tr>
                                    <th>성상</th>
                                    <td colspan="5" id="load-appearance"></td>
                                    <th>이론제조량</th>
                                    <td colspan="4"><span id="load-theor-qty"></span> <span id="load-theor-unit"></span></td>
                                </tr>
                                <tr>
                                    <th>향취</th>
                                    <td colspan="5" id="load-scent"></td>
                                    <th>제조수율</th>
                                    <td colspan="4"><span id="load-yield-rate"></span>%</td>
                                </tr>
                                <tr>
                                    <th>비중</th>
                                    <td colspan="5" id="load-specific-gravity"></td>
                                    <th>제조수율기준</th>
                                    <td colspan="4" id="load-yield-standard"></td>
                                </tr>
                                <tr>
                                    <th>ph</th>
                                    <td colspan="5" id="load-ph"></td>
                                    <td colspan="5" class="al-center">제조수율 = (실제제조량/이론제조량) * 100</td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                    <div class="bottom_btns">
                        <button type="button" id="cancelBtn" class="Button bgGray" data-width="180">취소</button>
                        <button type="button" id="requestBtn" class="Button bgBlue" data-width="180">요청</button>
                        <button type="button" id="modifyBtn" class="Button brdrGreen" data-width="180">수정</button>
                    </div>
                </div>
                <!--//Step2-->
            </div>
        </div>
    </div>

    <script>
        // 현재 선택된 order_id를 담아둘 전역 변수
        let currentOrderId = null;

        // 천단위 콤마 포맷 함수
        function formatWithComma(value) {
            if (!value && value !== 0) return "";
            let parts = value.toString().split('.');
            parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
            return parts.join('.');
        }

        $(document).ready(function() {
            // 1. jQuery UI 자동완성 설정 (제품명 검색)
            $("#searchProductName").autocomplete({
                source: function(request, response) {
                    $.ajax({
                        url: "getWorkOrderAutoComplete.jsp",
                        type: "GET",
                        data: { term: request.term },
                        dataType: "json",
                        success: function(data) {
                            response(data);
                        }
                    });
                },
                minLength: 1,
                select: function(event, ui) {
                    $("#searchProductName").val(ui.item.value); // 입력창엔 제품명 입력
                    currentOrderId = ui.item.orderId; // 선택된 order_id 저장
                    loadWorkOrderData(ui.item.orderId);
                    return false;
                }
            });

            // 2. 취소 버튼 클릭 이벤트: Step2 숨기고 Step1(검색창) 노출 및 초기화
            $("#cancelBtn").on("click", function() {
                $("#step2Area").hide();
                $("#step1Area").show();
                $("#searchProductName").val("");
                currentOrderId = null;
            });

            // 3. 수정 버튼 클릭 이벤트: 연결된 order_id를 들고 workOrderModify.jsp로 이동
            $("#modifyBtn").on("click", function() {
                if (!currentOrderId) {
                    alert("수정할 데이터의 정보가 없습니다.");
                    return;
                }
                location.href = "/app/workOrder/workOrderModify.jsp?order_id=" + currentOrderId;
            });

            // 4. 요청 버튼 클릭 이벤트: 제조요청 등록 + 구글챗 알림 전송 (workOrderRequestAction.jsp)
            $("#requestBtn").on("click", function() {
                if (!currentOrderId) {
                    alert("요청할 데이터의 정보가 없습니다.");
                    return;
                }

                if (!confirm("해당 제품의 제조요청을 등록하시겠습니까?")) {
                    return;
                }

                let $btn = $(this);
                $btn.prop("disabled", true); // 중복 클릭 방지

                $.ajax({
                    url: "workOrderRequestAction.jsp",
                    type: "POST",
                    data: { order_id: currentOrderId },
                    dataType: "json",
                    success: function(res) {
                        if (res && res.success) {
                            alert(res.message || "제조요청이 등록되었습니다.");
                            location.href = "/app/workOrderProgress/workOrderProgressList.jsp";
                        } else {
                            alert(res && res.message ? res.message : "제조요청 등록에 실패했습니다.");
                            $btn.prop("disabled", false);
                        }
                    },
                    error: function() {
                        alert("서버 통신 중 오류가 발생했습니다.");
                        $btn.prop("disabled", false);
                    }
                });
            });
        });

        // 5. 선택된 제품의 DB 데이터를 가져와서 테이블에 렌더링 (phase rowspan 계산 포함)
        function loadWorkOrderData(orderId) {
            currentOrderId = orderId; // 함수 호출 시에도 안전하게 세팅

            $.ajax({
                url: "getWorkOrderDetail.jsp",
                type: "GET",
                data: { order_id: orderId },
                dataType: "json",
                success: function(res) {
                    if (!res || !res.master) {
                        alert("데이터를 불러오지 못했습니다.");
                        return;
                    }

                    let m = res.master;
                    let items = res.items || [];
                    let phases = res.phases || [];

                    // 마스터 정보 맵핑
                    $("#load-product-name").text(m.product_name || "");
                    $("#load-target-qty").text(m.target_qty || 0);
                    $("#load-target-unit").text(m.target_unit || "kg");
                    $("#load-machine").text(m.machine || "");
                    $("#load-manager-name").text(m.manager_name || "");
                    $("#load-appearance").text(m.appearance || "");
                    $("#load-scent").text(m.scent || "");
                    $("#load-specific-gravity").text(m.specific_gravity || "");
                    $("#load-ph").text(m.ph || "");
                    $("#load-theor-qty").text(m.theor_qty || 0);
                    $("#load-theor-unit").text(m.theor_unit || "kg");
                    $("#load-yield-rate").text(m.yield_rate || 0);
                    $("#load-yield-standard").text(m.yield_standard || "");

                    let tbodyHtml = "";
                    let totalPct = 0;
                    let totalKg = 0;
                    let totalG = 0;

                    let rowPhaseMap = {};
                    phases.forEach(function(p) {
                        let start = parseInt(p.phase_select_start) || 1;
                        let end = parseInt(p.phase_select_end) || 1;
                        let spanCount = (end - start) + 1;
                        
                        rowPhaseMap[start] = {
                            phaseName: p.phase_name,
                            methodDesc: p.method_desc,
                            noteDesc: p.note_desc,
                            rowspan: spanCount
                        };
                        for (let r = start + 1; r <= end; r++) {
                            rowPhaseMap[r] = { skip: true };
                        }
                    });

                    // 원료 목록 테이블 렌더링
                    items.forEach(function(item, idx) {
                        let rowNum = idx + 1;
                        totalPct += parseFloat(item.content_pct) || 0;
                        totalKg += parseFloat(item.order_qty_kg) || 0;
                        totalG += parseFloat(item.order_qty_g) || 0;

                        tbodyHtml += `<tr>`;

                        if (rowPhaseMap[rowNum]) {
                            if (!rowPhaseMap[rowNum].skip) {
                                let pInfo = rowPhaseMap[rowNum];
                                let formattedMethod = (pInfo.methodDesc || '').replace(/\(/g, '<br>(');

                                tbodyHtml += `<td class="al-center" rowspan="\${pInfo.rowspan}">\${pInfo.phaseName}</td>`;
                                tbodyHtml += `<td class="al-center">\${rowNum}</td>`;
                                tbodyHtml += `<td class="name"><span>\${item.raw_material_name || ''}</span></td>`;
                                tbodyHtml += `<td class="al-center">\${item.test_number || ''}</td>`;
                                tbodyHtml += `<td class="al-right">\${formatWithComma(item.content_pct || 0)} %</td>`;
                                tbodyHtml += `<td class="al-right">\${formatWithComma(item.order_qty_kg || 0)} kg</td>`;
                                tbodyHtml += `<td class="al-right">\${formatWithComma(item.order_qty_g || 0)} g</td>`;
                                tbodyHtml += `<td class="al-center" colspan="2" rowspan="\${pInfo.rowspan}">\${formattedMethod}</td>`;
                                tbodyHtml += `<td class="al-center" colspan="2" rowspan="\${pInfo.rowspan}">\${pInfo.noteDesc || ''}</td>`;
                            } else {
                                tbodyHtml += `<td class="al-center">\${rowNum}</td>`;
                                tbodyHtml += `<td class="name"><span>\${item.raw_material_name || ''}</span></td>`;
                                tbodyHtml += `<td class="al-center">\${item.test_number || ''}</td>`;
                                tbodyHtml += `<td class="al-right">\${formatWithComma(item.content_pct || 0)} %</td>`;
                                tbodyHtml += `<td class="al-right">\${formatWithComma(item.order_qty_kg || 0)} kg</td>`;
                                tbodyHtml += `<td class="al-right">\${formatWithComma(item.order_qty_g || 0)} g</td>`;
                            }
                        } else {
                            tbodyHtml += `<td>-</td>`;
                            tbodyHtml += `<td class="al-center">\${rowNum}</td>`;
                            tbodyHtml += `<td class="name"><span>\${item.raw_material_name || ''}</span></td>`;
                            tbodyHtml += `<td class="al-center">\${item.test_number || ''}</td>`;
                            tbodyHtml += `<td class="al-right">\${formatWithComma(item.content_pct || 0)} %</td>`;
                            tbodyHtml += `<td class="al-right">\${formatWithComma(item.order_qty_kg || 0)} kg</td>`;
                            tbodyHtml += `<td class="al-right">\${formatWithComma(item.order_qty_g || 0)} g</td>`;
                            tbodyHtml += `<td class="al-center" colspan="2"></td>`;
                            tbodyHtml += `<td class="al-center" colspan="2"></td>`;
                        }

                        tbodyHtml += `</tr>`;
                    });

                    $("#load-items-tbody").html(tbodyHtml);

                    // 합계 영역 소수점 제거 및 단위 부착
                    $("#load-total-pct").text(formatWithComma(Math.round(totalPct)) + " %");
                    $("#load-total-kg").text(formatWithComma(Math.round(totalKg)) + " kg");
                    $("#load-total-g").text(formatWithComma(Math.round(totalG)) + " g");

                    // Step2 영역 노출
                    $("#step1Area").hide();
                    $("#step2Area").show();
                },
                error: function() {
                    alert("상세 데이터를 가져오는 중 오류가 발생했습니다.");
                }
            });
        }
    </script>
<jsp:include page="/app/include/FooterDocType.jsp" />