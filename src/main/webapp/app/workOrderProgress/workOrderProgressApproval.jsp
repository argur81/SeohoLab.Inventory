<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String requestIdStr = request.getParameter("request_id");
%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
<div id="loadingOverlay">
    <div class="spinner"></div>
    <p class="loading_text">데이터를 불러오는 중입니다...</p>
</div>
<div id="wrap">
    <jsp:include page="/app/include/Header.jsp" />
    <div id="container">
        <div class="content workOrderProgressDetail">
            <div class="title_set">
                <h5 class="page_tit">
                    <p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>진행현황</b><i><img src="/images/svg/location_arrow.svg"></i>승인요청</b>
                </h5>
            </div>
            <section class="radius">
                <div class="road_data">
                    <table>
                        <colgroup>
                            <col width="100"><col width="45"><col width="220"><col width="130">
                            <col width="110"><col width="120"><col width="120"><col width="170">
                            <col width="140"><col width="170">
                        </colgroup>
                        <thead>
                            <tr>
                                <th colspan="7" rowspan="3" class="doc_name">제조 지시 및 공정 기록서</th>
                                <th>작성</th><th>검토</th><th>승인</th>
                            </tr>
                            <tr>
                                <td class="sign">&nbsp;</td><td class="sign">&nbsp;</td><td class="sign">&nbsp;</td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
                            </tr>
                            <tr>
                                <th>제품명</th>
                                <td colspan="5" id="load-product-name"></td>
                                <th colspan="2">제조지시량</th>
                                <td colspan="2"><span id="load-target-qty"></span> <span id="load-target-unit"></span></td>
                            </tr>
                            <tr>
                                <th>제조번호</th>
                                <td colspan="2" id="load-batch-no"></td>
                                <td colspan="3" id="load-due-date"></td>
                                <th>제조지시자</th>
                                <td id="load-manager-name"></td>
                                <th>제조자</th>
                                <td id="load-maker-name"></td>
                            </tr>
                            <tr>
                                <th>제조기기</th>
                                <td colspan="5" id="load-machine"></td>
                                <th>제조지시일</th>
                                <td id="load-request-date"></td>
                                <th>제조일자</th>
                                <td id="load-mfg-date"></td>
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
                        <tbody id="load-items-tbody">
                            <!-- AJAX로 원료 행이 동적으로 삽입됩니다 -->
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="4">합계 (지시서 원료 기준)</th>
                                <td id="load-total-pct" class="al-right"></td>
                                <td id="load-total-kg" class="al-right"></td>
                                <td id="load-total-g" class="al-right"></td>
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
                                <td colspan="2" id="load-appearance"></td>
                                <td colspan="3" id="load-appearance-result"></td>
                                <th colspan="2">실제제조량</th>
                                <td colspan="2"><span id="load-actual-qty"></span> kg</td>
                            </tr>
                            <tr>
                                <th>향취</th>
                                <td colspan="2" id="load-scent"></td>
                                <td colspan="3" id="load-scent-result"></td>
                                <th colspan="2">제조수율</th>
                                <td colspan="2"><span id="load-yield-rate-actual"></span>%</td>
                            </tr>
                            <tr>
                                <th>비중</th>
                                <td colspan="2" id="load-specific-gravity"></td>
                                <td colspan="3" id="load-specific-gravity-result"></td>
                                <th colspan="2">제조수율기준</th>
                                <td colspan="2" id="load-yield-standard"></td>
                            </tr>
                            <tr>
                                <th>ph</th>
                                <td colspan="2" id="load-ph"></td>
                                <td colspan="3" id="load-ph-result"></td>
                                <td colspan="4" class="al-center">제조수율 = (실제제조량/이론제조량) * 100</td>
                            </tr>
                        </tfoot>
                    </table>
                </div>

                <div class="bottom_btns">
                    <button type="button" id="backListBtn" class="Button bgGray" data-width="180">목록</button>
                    <button type="button" id="reviseBtn" class="Button brdrYellow" data-width="180">보정</button>
                    <button type="button" id="approveBtn" class="Button bgBlue" data-width="180">승인</button>
                    <button type="button" id="discardBtn" class="Button brdrGray" data-width="180">폐기</button>
                    <button type="button" id="deleteBtn" class="Button brdrGray" data-width="180">삭제</button>
                </div>
            </section>
        </div>
    </div>
</div>

<script>
    let currentRequestId = "<%= requestIdStr != null ? requestIdStr : "" %>";

    function formatWithComma(value) {
        if (value === null || value === undefined || value === "") return "";
        let parts = value.toString().split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        return parts.join('.');
    }

    $(document).ready(function () {
        if (!currentRequestId) {
            alert("유효하지 않은 접근입니다. (요청 ID 누락)");
            history.back();
            return;
        }

        loadAllData(currentRequestId);

        $("#backListBtn").on("click", function () {
            location.href = "/app/workOrderProgress/workOrderProgressList.jsp";
        });

        // 보정: 진행현황을 '수정중'으로 바꾸고 workOrderProgressMaking.jsp로 돌아가 재편집
        $("#reviseBtn").on("click", function () {
            if (!confirm("이 제조 기록을 보정 하시겠습니까?")) return;

            $.ajax({
                url: "workOrderProgressReviseAction.jsp",
                type: "POST",
                data: { request_id: currentRequestId },
                dataType: "json",
                success: function (res) {
                    if (res && res.success) {
                        location.href = "/app/workOrderProgress/workOrderProgressMaking.jsp?request_id=" + currentRequestId;
                    } else {
                        alert(res && res.message ? res.message : "처리에 실패했습니다.");
                    }
                },
                error: function () { alert("서버 통신 중 오류가 발생했습니다."); }
            });
        });

        // 승인: 기존 [제조완료] 처리 로직 그대로 재사용 (원료 재고 차감 + 상태를 '제조완료'로 변경)
        $("#approveBtn").on("click", function () {
            if (!confirm("이 제조 기록을 승인하시겠습니까?\n(사용된 원료 재고가 차감됩니다)")) return;

            let $btn = $(this);
            $btn.prop("disabled", true);

            $.ajax({
                url: "workOrderProgressCompleteAction.jsp",
                type: "POST",
                data: { request_id: currentRequestId },
                dataType: "json",
                success: function (res) {
                    if (res && res.success) {
                        alert(res.message || "승인 처리되었습니다.");
                        location.href = "/app/workOrderProgress/workOrderProgressList.jsp";
                    } else {
                        alert(res && res.message ? res.message : "처리에 실패했습니다.");
                        $btn.prop("disabled", false);
                    }
                },
                error: function () {
                    alert("서버 통신 중 오류가 발생했습니다.");
                    $btn.prop("disabled", false);
                }
            });
        });

        $("#discardBtn").on("click", function () {
            if (!confirm("이 제조 기록을 폐기 처리하시겠습니까?\n(이미 투입된 원료 재고가 차감되며, 완제품은 생산되지 않습니다)")) return;

            let $btn = $(this);
            $btn.prop("disabled", true);

            $.ajax({
                url: "workOrderProgressDiscardAction.jsp",
                type: "POST",
                data: { request_id: currentRequestId },
                dataType: "json",
                success: function (res) {
                    if (res && res.success) {
                        alert(res.message || "폐기 처리되었습니다.");
                        location.href = "/app/workOrderProgress/workOrderProgressList.jsp";
                    } else {
                        alert(res && res.message ? res.message : "처리에 실패했습니다.");
                        $btn.prop("disabled", false);
                    }
                },
                error: function () {
                    alert("서버 통신 중 오류가 발생했습니다.");
                    $btn.prop("disabled", false);
                }
            });
        });

        $("#deleteBtn").on("click", function () {
            if (!confirm("정말 이 제조 기록을 삭제하시겠습니까?")) return;
            $.ajax({
                url: "workOrderProgressDeleteAction.jsp",
                type: "POST",
                data: { request_id: currentRequestId },
                dataType: "json",
                success: function (res) {
                    if (res && res.success) {
                        alert("삭제되었습니다.");
                        location.href = "/app/workOrderProgress/workOrderProgressList.jsp";
                    } else {
                        alert(res && res.message ? res.message : "삭제에 실패했습니다.");
                    }
                },
                error: function () { alert("서버 통신 중 오류가 발생했습니다."); }
            });
        });
    });

    // 지시서 원본 + 제조 최종 데이터를 불러와서 화면에 채움 (읽기 전용, 값만 표시)
    function loadAllData(requestId) {
        $.ajax({
            url: "getWorkOrderProgressDetail.jsp",
            type: "GET",
            data: { request_id: requestId },
            dataType: "json",
            success: function (res) {
                if (!res || !res.request) {
                    alert("데이터를 불러오지 못했습니다.");
                    return;
                }

                let req = res.request;
                let m = res.master || {};
                let items = res.items || [];
                let phases = res.phases || [];

                $("#load-product-name").text(req.product_name || "");
                $("#load-target-qty").text(req.target_qty || 0);
                $("#load-target-unit").text(req.target_unit || "kg");
                $("#load-machine").text(m.machine || "");
                $("#load-manager-name").text(req.manager_name || m.manager_name || "");
                if (req.request_date) {
                    $("#load-request-date").text(req.request_date.substring(0, 10));
                }
                $("#load-appearance").text(m.appearance || "");
                $("#load-scent").text(m.scent || "");
                $("#load-specific-gravity").text(m.specific_gravity || "");
                $("#load-ph").text(m.ph || "");
                $("#load-theor-qty").text(m.theor_qty || 0);
                $("#load-theor-unit").text(m.theor_unit || "kg");
                $("#load-yield-standard").text(m.yield_standard || "");

                renderItemsTable(items, phases);

                $.ajax({
                    url: "getWorkOrderMakingData.jsp",
                    type: "GET",
                    data: { request_id: requestId },
                    dataType: "json",
                    success: function (mk) {
                        applyMakingData(mk);
                        $('#loadingOverlay').fadeOut(500);
                    },
                    error: function () { $('#loadingOverlay').fadeOut(500); }
                });
            },
            error: function () {
                alert("데이터를 가져오는 중 오류가 발생했습니다.");
                $('#loadingOverlay').fadeOut(500);
            }
        });
    }

    // 투입량 값+단위를 하나의 텍스트로 포맷 (예: "12,193.5 g")
    function formatQtyText(qty, unit) {
        if (!qty || qty <= 0) return "";
        return formatWithComma(qty) + " " + (unit || "g");
    }

    // 원료 목록 테이블 렌더링 (지시서 원료, 상/제조방법/비고는 rowspan 처리) - 값만 표시
    function renderItemsTable(items, phases) {
        let tbodyHtml = "";
        let totalPct = 0, totalKg = 0, totalG = 0;

        let rowPhaseMap = {};
        phases.forEach(function (p) {
            let start = parseInt(p.phase_select_start) || 1;
            let end = parseInt(p.phase_select_end) || 1;
            let spanCount = (end - start) + 1;
            rowPhaseMap[start] = {
                phaseName: p.phase_name, methodDesc: p.method_desc, noteDesc: p.note_desc, rowspan: spanCount
            };
            for (let r = start + 1; r <= end; r++) rowPhaseMap[r] = { skip: true };
        });

        items.forEach(function (item, idx) {
            let rowNum = idx + 1;
            totalPct += parseFloat(item.content_pct) || 0;
            totalKg += parseFloat(item.order_qty_kg) || 0;
            totalG += parseFloat(item.order_qty_g) || 0;

            let lotCell = '<td class="al-center lot-cell" data-row="' + rowNum + '"></td>';
            let qtyCell = '<td class="al-right qty-cell" data-row="' + rowNum + '"></td>';

            let rowHtml = '<tr data-row-id="' + rowNum + '">';

            if (rowPhaseMap[rowNum] && !rowPhaseMap[rowNum].skip) {
                let pInfo = rowPhaseMap[rowNum];
                let formattedMethod = (pInfo.methodDesc || '').replace(/\(/g, '<br>(');
                rowHtml += '<td class="al-center" rowspan="' + pInfo.rowspan + '">' + (pInfo.phaseName || '') + '</td>';
                rowHtml += '<td class="al-center">' + rowNum + '</td>';
                rowHtml += '<td>' + (item.raw_material_name || '') + '</td>';
                rowHtml += lotCell;
                rowHtml += '<td class="al-right">' + formatWithComma(item.content_pct || 0) + ' %</td>';
                rowHtml += '<td class="al-right">' + formatWithComma(item.order_qty_kg || 0) + ' kg</td>';
                rowHtml += '<td class="al-right">' + formatWithComma(item.order_qty_g || 0) + ' g</td>';
                rowHtml += qtyCell;
                rowHtml += '<td class="al-center" rowspan="' + pInfo.rowspan + '">' + formattedMethod + '</td>';
                rowHtml += '<td class="al-center" rowspan="' + pInfo.rowspan + '">' + (pInfo.noteDesc || '') + '</td>';
            } else if (rowPhaseMap[rowNum] && rowPhaseMap[rowNum].skip) {
                rowHtml += '<td class="al-center">' + rowNum + '</td>';
                rowHtml += '<td>' + (item.raw_material_name || '') + '</td>';
                rowHtml += lotCell;
                rowHtml += '<td class="al-right">' + formatWithComma(item.content_pct || 0) + ' %</td>';
                rowHtml += '<td class="al-right">' + formatWithComma(item.order_qty_kg || 0) + ' kg</td>';
                rowHtml += '<td class="al-right">' + formatWithComma(item.order_qty_g || 0) + ' g</td>';
                rowHtml += qtyCell;
            } else {
                rowHtml += '<td>-</td>';
                rowHtml += '<td class="al-center">' + rowNum + '</td>';
                rowHtml += '<td>' + (item.raw_material_name || '') + '</td>';
                rowHtml += lotCell;
                rowHtml += '<td class="al-right">' + formatWithComma(item.content_pct || 0) + ' %</td>';
                rowHtml += '<td class="al-right">' + formatWithComma(item.order_qty_kg || 0) + ' kg</td>';
                rowHtml += '<td class="al-right">' + formatWithComma(item.order_qty_g || 0) + ' g</td>';
                rowHtml += qtyCell;
                rowHtml += '<td></td><td></td>';
            }

            rowHtml += '</tr>';
            tbodyHtml += rowHtml;
        });

        $("#load-items-tbody").html(tbodyHtml);
        $("#load-total-pct").text(formatWithComma(Math.round(totalPct)) + " %");
        $("#load-total-kg").text(formatWithComma(Math.round(totalKg)) + " kg");
        $("#load-total-g").text(formatWithComma(Math.round(totalG)) + " g");
    }

    // 제조중 저장된 최종 데이터를 화면에 반영 (지시서 원료 + 제조 중 추가원료 모두, 값만 표시)
    function applyMakingData(mk) {
        if (mk && mk.making) {
            let hdr = mk.making;
            $("#load-batch-no").text(hdr.batch_no || "-");
            $("#load-due-date").text(hdr.due_date ? (hdr.due_date + " 까지") : "");
            $("#load-maker-name").text(hdr.maker_name || "");
            $("#load-mfg-date").text(hdr.mfg_date || "");
            $("#load-appearance-result").text(hdr.appearance_result || "");
            $("#load-scent-result").text(hdr.scent_result || "");
            $("#load-specific-gravity-result").text(hdr.specific_gravity_result || "");
            $("#load-ph-result").text(hdr.ph_result || "");
            $("#load-actual-qty").text(formatWithComma(hdr.actual_qty || 0));
            $("#load-yield-rate-actual").text(hdr.yield_rate_actual || 0);
        }

        if (mk && mk.items && mk.items.length > 0) {
            let extraRows = mk.items.filter(function (it) { return it.is_extra === 1; });
            extraRows.forEach(function (it) {
                let rowHtml = '<tr data-row-id="' + it.item_row_id + '" class="extra-row">'
                    + '<td class="al-center">-</td>'
                    + '<td class="al-center">' + it.item_row_id + '</td>'
                    + '<td>' + (it.raw_material_name || '') + '</td>'
                    + '<td class="al-center lot-cell" data-row="' + it.item_row_id + '"></td>'
                    + '<td class="al-center">-</td>'
                    + '<td class="al-center">-</td>'
                    + '<td class="al-center">-</td>'
                    + '<td class="al-right qty-cell" data-row="' + it.item_row_id + '"></td>'
                    + '<td>-</td>'
                    + '<td>' + (it.note || '(제조 중 추가)') + '</td>'
                    + '</tr>';
                $("#load-items-tbody").append(rowHtml);
            });

            mk.items.forEach(function (it) {
                $('.lot-cell[data-row="' + it.item_row_id + '"]').text(it.lot_numbers || "");
                $('.qty-cell[data-row="' + it.item_row_id + '"]').text(formatQtyText(it.input_qty, it.input_unit));
            });
        }
    }
</script>
<jsp:include page="/app/include/FooterDocType.jsp" />
