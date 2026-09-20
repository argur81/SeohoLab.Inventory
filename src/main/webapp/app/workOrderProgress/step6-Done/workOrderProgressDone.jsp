<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String requestIdStr = request.getParameter("request_id");
%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
<style>
    /* 인쇄 시 표(road_data) 영역만 출력 */
    @media print {
        body * { visibility: hidden; }
        .road_data, .road_data * { visibility: visible; }
        .road_data { position: absolute; left: 0; top: 0; width: 100%; }
        #loadingOverlay, .top_btn, .bottom_btns, header { display: none !important; }
    }
    @page {
        size: A4;
        margin: 10mm;
    }
</style>
<div id="loadingOverlay">
    <div class="spinner"></div>
    <p class="loading_text">Loading</p>
</div>
<div id="wrap">
    <jsp:include page="/app/include/Header.jsp" />
    <div id="container">
        <div class="content workOrderProgressMaking">
            <div class="title_set">
                <h5 class="page_tit">
                    <p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>진행현황</b><i><img src="/images/svg/location_arrow.svg"></i>생산완료</b>
                    <button type="button" class="toggle"></button>
                </h5>
            </div>
            <section class="radius">
                <div class="road_data">
                    <table class="requestTable workOrderMakingTable">
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
                                <td colspan="3" data-roll="성상결과" id="load-appearance-result" class="result"></td>
                                <th colspan="2">실제제조량</th>
                                <td colspan="2"><span id="load-actual-qty"></span> kg</td>
                            </tr>
                            <tr>
                                <th>향취</th>
                                <td colspan="2" id="load-scent"></td>
                                <td colspan="3" data-roll="향취결과" id="load-scent-result" class="result"></td>
                                <th colspan="2">제조수율</th>
                                <td colspan="2"><span id="load-yield-rate-actual"></span>%</td>
                            </tr>
                            <tr>
                                <th>비중</th>
                                <td colspan="2" id="load-specific-gravity"></td>
                                <td colspan="3" data-roll="비중결과" id="load-specific-gravity-result" class="result"></td>
                                <th colspan="2">제조수율기준</th>
                                <td colspan="2" id="load-yield-standard"></td>
                            </tr>
                            <tr>
                                <th>ph</th>
                                <td colspan="2" id="load-ph"></td>
                                <td colspan="3" data-roll="ph결과" id="load-ph-result" class="result"></td>
                                <td colspan="4" class="al-center">제조수율 = (실제제조량/이론제조량) * 100</td>
                            </tr>
                        </tfoot>
                    </table>
                </div>

                <div class="bottom_btns">
                    <button type="button" id="backListBtn" class="Button bgGray" data-width="180">목록</button>
                    <button type="button" id="printBtn" class="Button brdrYellow" data-width="180">인쇄</button>
                    <button type="button" id="excelBtn" class="Button brdrGreen" data-width="180">엑셀저장</button>
                    <button type="button" id="deleteBtn" class="Button brdrGray" data-width="180">삭제</button>
                </div>
            </section>
        </div>
    </div>
</div>

<script>
    let currentRequestId = "<%= requestIdStr != null ? requestIdStr : "" %>";
    let currentBatchNo = "";
    let currentProductName = "";
    let currentRequestDate = "";

    function formatWithComma(value) {
        if (value === null || value === undefined || value === "") return "";
        let parts = value.toString().split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        return parts.join('.');
    }

    // ISO 날짜 문자열("2029-08-14") -> "290814" (제조번호 스타일과 통일된 EXP 표기)
    function formatExpYYMMDD(isoDateStr) {
        if (!isoDateStr) return "";
        let parts = isoDateStr.split('-');
        if (parts.length !== 3) return isoDateStr;
        return parts[0].slice(-2) + parts[1] + parts[2];
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

        $("#printBtn").on("click", function () {
            printFitToA4();
        });

        $("#excelBtn").on("click", function () {
            exportToExcel();
        });

        $("#deleteBtn").on("click", function () {
            if (!confirm("정말 이 제조 기록을 삭제하시겠습니까?\n(완료된 기록이 영구 삭제됩니다)")) return;
            $.ajax({
                url: "/app/workOrderProgress/common/workOrderProgressDeleteAction.jsp",
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

    // 인쇄 시 A4 한 장에 맞도록 자동 축소 (zoom 사용 - 레이아웃 크기 자체가 줄어들어 페이지분할에도 반영됨)
    function printFitToA4() {
        let $road = $(".road_data");
        $road.css("zoom", "1");

        let contentHeightPx = $road[0].scrollHeight;
        let contentWidthPx = $road[0].scrollWidth;

        const A4_HEIGHT_PX = Math.round((297 - 20) * 3.78);
        const A4_WIDTH_PX = Math.round((210 - 20) * 3.78);

        let scaleH = A4_HEIGHT_PX / contentHeightPx;
        let scaleW = A4_WIDTH_PX / contentWidthPx;
        let scale = Math.min(scaleH, scaleW, 1);

        if (scale < 1) {
            $road.css("zoom", scale);
        }

        window.print();

        let restore = function () { $road.css("zoom", "1"); };
        window.onafterprint = restore;
        setTimeout(restore, 1000);
    }

    // 엑셀 저장 (표 전체가 순수 텍스트라서 그대로 내보내면 됨)
    // 파일명에 쓸 수 없는 문자(\ / : * ? " < > |) 제거
    function sanitizeFileName(str) {
        return (str || "").replace(/[\\/:*?"<>|]/g, "").trim();
    }

    function exportToExcel() {
        let tableHtml = $(".road_data table").prop("outerHTML");

        // 엑셀은 외부 CSS(style.css)를 못 읽으므로, 인쇄화면과 같은 테두리/정렬을 <style>로 직접 넣어줌
        let styleBlock = '<style>'
            + 'table { border-collapse: collapse; width: 100%; font-family: "맑은 고딕", sans-serif; font-size: 12px; }'
            + 'th, td { border: 1px solid #000; padding: 4px 6px; text-align: center; vertical-align: middle; }'
            + 'th { background-color: #f2f2f2; font-weight: bold; }'
            + '.al-left { text-align: left; }'
            + '.al-right { text-align: right; }'
            + '.al-center { text-align: center; }'
            + '.name { text-align: left; }'
            + '.doc_name { font-size: 16px; }'
            + '</style>';

        let html = '<html><head><meta charset="utf-8"/>' + styleBlock + '</head><body>' + tableHtml + '</body></html>';

        let blob = new Blob([html], { type: 'application/vnd.ms-excel;charset=utf-8;' });
        let link = document.createElement('a');
        link.href = URL.createObjectURL(blob);

        // 파일명: 제조지시일 + 제품명(Lot번호)
        let datePart = sanitizeFileName(currentRequestDate) || sanitizeFileName(new Date().toISOString().slice(0, 10));
        let namePart = sanitizeFileName(currentProductName) || ("request_" + currentRequestId);
        let lotPart = sanitizeFileName(currentBatchNo);

        let fileName = datePart + " " + namePart + (lotPart ? "(" + lotPart + ")" : "");

        link.download = fileName + '.xls';
        link.click();
    }

    // 지시서 원본 + 제조 최종 데이터를 불러와서 화면에 채움 (읽기 전용, 값만 표시)
    function loadAllData(requestId) {
        $.ajax({
            url: "/app/workOrderProgress/common/getWorkOrderProgressDetail.jsp",
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

                currentProductName = req.product_name || "";

                $("#load-product-name").text(req.product_name || "");
                $("#load-target-qty").text(req.target_qty || 0);
                $("#load-target-unit").text(req.target_unit || "kg");
                $("#load-machine").text(m.machine || "");
                $("#load-manager-name").text(req.manager_name || m.manager_name || "");
                if (req.request_date) {
                    currentRequestDate = req.request_date.substring(0, 10); // yyyy-mm-dd
                    $("#load-request-date").text(currentRequestDate);
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
                    url: "/app/workOrderProgress/common/getWorkOrderMakingData.jsp",
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

    // 원료 목록 테이블 렌더링 (지시서 원료, 상/제조방법/비고는 rowspan 처리) - 값만 표시 (input 없음)
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

            let lotCell = '<td data-roll="Lot" class="al-center lot-cell lot" data-row="' + rowNum + '"></td>';
            let qtyCell = '<td data-roll="투입량" class="al-right qty-cell enter" data-row="' + rowNum + '"></td>';

            let rowHtml = '<tr data-row-id="' + rowNum + '">';

            if (rowPhaseMap[rowNum] && !rowPhaseMap[rowNum].skip) {
                let pInfo = rowPhaseMap[rowNum];
                let formattedMethod = (pInfo.methodDesc || '').replace(/\(/g, '<br>(');
                rowHtml += '<td class="al-center phase" rowspan="' + pInfo.rowspan + '">' + (pInfo.phaseName || '') + '</td>';
                rowHtml += '<td class="al-center no">' + rowNum + '</td>';
                rowHtml += '<td class="name">' + (item.raw_material_name || '') + '</td>';
                rowHtml += lotCell;
                rowHtml += '<td data-roll="함량(%)" class="al-right content_pct">' + formatWithComma(item.content_pct || 0) + ' %</td>';
                rowHtml += '<td data-roll="제조지시량(kg)" class="al-right kg">' + formatWithComma(item.order_qty_kg || 0) + ' kg</td>';
                rowHtml += '<td data-roll="제조지시량(g)" class="al-right g">' + formatWithComma(item.order_qty_g || 0) + ' g</td>';
                rowHtml += qtyCell;
                rowHtml += '<td data-roll="제조방법" class="al-center method" rowspan="' + pInfo.rowspan + '">' + formattedMethod + '</td>';
                rowHtml += '<td data-roll="비고" class="al-center note" rowspan="' + pInfo.rowspan + '">' + (pInfo.noteDesc || '') + '</td>';
            } else if (rowPhaseMap[rowNum] && rowPhaseMap[rowNum].skip) {
                rowHtml += '<td class="al-center no">' + rowNum + '</td>';
                rowHtml += '<td class="name">' + (item.raw_material_name || '') + '</td>';
                rowHtml += lotCell;
                rowHtml += '<td data-roll="함량(%)" class="al-right content_pct">' + formatWithComma(item.content_pct || 0) + ' %</td>';
                rowHtml += '<td data-roll="제조지시량(kg)" class="al-right kg">' + formatWithComma(item.order_qty_kg || 0) + ' kg</td>';
                rowHtml += '<td data-roll="제조지시량(g)" class="al-right g">' + formatWithComma(item.order_qty_g || 0) + ' g</td>';
                rowHtml += qtyCell;
            } else {
                rowHtml += '<td>-</td>';
                rowHtml += '<td class="al-center no">' + rowNum + '</td>';
                rowHtml += '<td>' + (item.raw_material_name || '') + '</td>';
                rowHtml += lotCell;
                rowHtml += '<td data-roll="함량(%)" class="al-right content_pct">' + formatWithComma(item.content_pct || 0) + ' %</td>';
                rowHtml += '<td data-roll="제조지시량(kg)" class="al-right kg">' + formatWithComma(item.order_qty_kg || 0) + ' kg</td>';
                rowHtml += '<td data-roll="제조지시량(g)" class="al-right g">' + formatWithComma(item.order_qty_g || 0) + ' g</td>';
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

        //제조지시서 테이블 Mobile
        $('.workOrderMakingTable tbody tr').each(function () {
            var $lastTd = $(this).children('td').last();
            if ($lastTd.hasClass('note') == true) {
                $(this).addClass('has_rowspan');
            }
        });
        function workOrderResponsiveTable() {
            $('.workOrderMakingTable tr.has_rowspan').each(function () {
                if ($(window).width() <= 960) {
                    var thisPhaseHT = $(this).find('.phase').outerHeight();
                    var thisMethodHT = $(this).find('.method').outerHeight();
                    var thisNoteHT = $(this).find('.note').outerHeight();
                    $(this).css('padding-top', thisPhaseHT + thisNoteHT + thisMethodHT);
                    $(this).find('.method').css('top', thisPhaseHT);
                    $(this).find('.note').css('top', thisPhaseHT + thisMethodHT);
                } else {
                    $(this).css('padding', 0);
                }
            });
        }
        workOrderResponsiveTable();
        $(window).resize(function () {
            workOrderResponsiveTable();
        });
    }

    // 제조중 저장된 최종 데이터를 화면에 반영 (지시서 원료 + 제조 중 추가원료 모두, 값만 표시)
    function applyMakingData(mk) {
        if (mk && mk.making) {
            let hdr = mk.making;
            currentBatchNo = hdr.batch_no || "";
            $("#load-batch-no").text(hdr.batch_no || "-");
            $("#load-due-date").text(hdr.due_date ? ("EXP " + formatExpYYMMDD(hdr.due_date)) : "");
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
            // 1) 제조 중 추가로 등록된 원료(pH 조정 등) 행을 표 마지막에 별도로 추가
            let extraRows = mk.items.filter(function (it) { return it.is_extra === 1; });
            extraRows.forEach(function (it) {
                let rowHtml = '<tr data-row-id="' + it.item_row_id + '" class="extra-row">'
                    + '<td class="al-center">-</td>'
                    + '<td class="al-center">' + it.item_row_id + '</td>'
                    + '<td class="name">' + (it.raw_material_name || '') + '</td>'
                    + '<td data-roll="Lot" class="al-center lot-cell lot" data-row="' + it.item_row_id + '"></td>'
                    + '<td data-roll="함량(%)" class="al-center content_pct">-</td>'
                    + '<td data-roll="제조지시량(kg)" class="al-center kg">-</td>'
                    + '<td data-roll="제조지시량(g)" class="al-center g">-</td>'
                    + '<td data-roll="투입량" class="al-right qty-cell enter" data-row="' + it.item_row_id + '"></td>'
                    + '<td>-</td>'
                    + '<td>' + (it.note || '(제조 중 추가)') + '</td>'
                    + '</tr>';
                $("#load-items-tbody").append(rowHtml);
            });

            // 2) 지시서 원료 + 추가원료 모두에 Lot/투입량 값 채우기 (순수 텍스트)
            mk.items.forEach(function (it) {
                $('.lot-cell[data-row="' + it.item_row_id + '"]').text(it.lot_numbers || "");
                $('.qty-cell[data-row="' + it.item_row_id + '"]').text(formatQtyText(it.input_qty, it.input_unit));
            });
        }
    }
    $(document).ready(function(){
        $('#container').stop().delay(10).animate({'padding-left' : 0});
        $('header').stop().animate({'left' : -280});
        $('h5.page_tit .toggle').fadeIn();
    });
</script>
<jsp:include page="/app/include/FooterDocType.jsp" />
