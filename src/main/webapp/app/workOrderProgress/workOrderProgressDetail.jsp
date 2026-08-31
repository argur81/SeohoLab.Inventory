<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String requestIdStr = request.getParameter("request_id");
%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
<div id="wrap">
    <jsp:include page="/app/include/Header.jsp" />
    <div id="container">
        <div class="content workOrderProgressDetail">
            <div class="title_set">
                <h5 class="page_tit">
                    <p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>진행현황</b><i><img src="/images/svg/location_arrow.svg"></i>상세</b>
                </h5>
            </div>
            <section class="radius">
                <div class="road_data">
                    <table>
                        <colgroup>
                            <col width="100">
                            <col width="60">
                            <col width="240">
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
                                <td colspan="2" id="load-request-date"></td>
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
                            <!-- AJAX 동적 행 렌더링 -->
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="4">합계</th>
                                <td id="load-total-pct" class="al-right"></td>
                                <td id="load-total-kg" class="al-right"></td>
                                <td id="load-total-g" class="al-right"></td>
                                <td colspan="4">&nbsp;</td>
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
                    <button type="button" id="backListBtn" class="Button bgGray" data-width="180">목록</button>
                    <button type="button" id="startProgressBtn" class="Button bgBlue" data-width="180">제조시작</button>
                    <button type="button" id="deleteBtn" class="Button brdrGray" data-width="180">삭제</button>
                </div>
            </section>
        </div>
    </div>
</div>

<script>
    let currentRequestId = "<%= requestIdStr != null ? requestIdStr : "" %>";

    function formatWithComma(value) {
        if (!value && value !== 0) return "";
        let parts = value.toString().split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        return parts.join('.');
    }

    $(document).ready(function() {
        if (currentRequestId) {
            loadProgressDetailData(currentRequestId);
        } else {
            alert("유효하지 않은 접근입니다. (요청 ID 누락)");
            history.back();
        }
        // 제조시작 버튼
        $("#startProgressBtn").on("click", function () {
            if (!confirm("제조를 시작하시겠습니까?")) return;

            $.ajax({
                url: "workOrderProgressMakingAction.jsp",
                type: "POST",
                data: { request_id: currentRequestId },
                dataType: "json",
                success: function (res) {
                    if (res && res.success) {
                        // 성공 시 workOrderProgressMaking.jsp로 이동 (request_id 전달)
                        location.href = "workOrderProgressMaking.jsp?request_id=" + currentRequestId;
                    } else {
                        alert(res && res.message ? res.message : "제조 시작 처리에 실패했습니다.");
                    }
                },
                error: function () {
                    alert("서버 통신 중 오류가 발생했습니다.");
                }
            });
        });

        // 목록 버튼
        $("#backListBtn").on("click", function() {
            location.href = "/app/workOrderProgress/workOrderProgressList.jsp";
        });

        // 삭제 버튼
        $("#deleteBtn").on("click", function() {
            if (!confirm("정말 이 제조요청을 삭제하시겠습니까?")) return;
            
            $.ajax({
                url: "workOrderProgressDeleteAction.jsp",
                type: "POST",
                data: { request_id: currentRequestId },
                dataType: "json",
                success: function(res) {
                    if (res && res.success) {
                        alert("삭제되었습니다.");
                        location.href = "/app/workOrderProgress/workOrderProgressList.jsp";
                    } else {
                        alert(res && res.message ? res.message : "삭제에 실패했습니다.");
                    }
                },
                error: function() {
                    alert("서버 통신 중 오류가 발생했습니다.");
                }
            });
        });
    });

    function loadProgressDetailData(requestId) {
        $.ajax({
            url: "getWorkOrderProgressDetail.jsp",
            type: "GET",
            data: { request_id: requestId },
            dataType: "json",
            success: function(res) {
                if (!res || !res.request) {
                    alert("데이터를 불러오지 못했습니다.");
                    return;
                }

                let req = res.request;
                let m = res.master || {};
                let items = res.items || [];
                let phases = res.phases || [];

                // 마스터 및 요청 정보 맵핑
                $("#load-product-name").text(req.product_name || "");
                $("#load-target-qty").text(req.target_qty || 0);
                $("#load-target-unit").text(req.target_unit || "kg");
                $("#load-machine").text(m.machine || "");
                $("#load-manager-name").text(req.manager_name || m.manager_name || "");
                
                if (req.request_date) {
                    $("#load-request-date").text(req.request_date.substring(0, 16));
                }

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

                $("#load-total-pct").text(formatWithComma(Math.round(totalPct)) + " %");
                $("#load-total-kg").text(formatWithComma(Math.round(totalKg)) + " kg");
                $("#load-total-g").text(formatWithComma(Math.round(totalG)) + " g");
            },
            error: function() {
                alert("상세 데이터를 가져오는 중 오류가 발생했습니다.");
            }
        });
    }
</script>
<jsp:include page="/app/include/FooterDocType.jsp" />