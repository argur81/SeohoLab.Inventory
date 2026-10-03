<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String requestIdStr = request.getParameter("request_id");
%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
<!-- CDN: PDF 저장 기능용 (html2canvas + jsPDF) -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<style>
    /* ── 인쇄: 기능 동작에 필요한 최소 규칙만 (디자인은 별도 CSS로 추가 예정) ── */
    @media print {
        body * { visibility: hidden; }
        .tab-content, .tab-content * { visibility: visible; }
        .tab-content { page-break-after: always; }
        .tab-content:last-of-type { page-break-after: auto; }
        #loadingOverlay, .top_btn, .bottom_btns, header, .tab_buttons, .no-print { display: none !important; }
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
    <div id="container" class="workOrderProgressDone">
        <div class="title_set">
            <h5 class="page_tit">
                <p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>진행현황</b><i><img src="/images/svg/location_arrow.svg"></i>생산완료
            </h5>
        </div>
        <div class="doneTabButtons">
            <button type="button" class="tab-btn active" data-tab="makingTabContent">제조 지시서</button>
            <button type="button" class="tab-btn" data-tab="fillingTabContent">포장 지시 및 기록서</button>
        </div>
        <!--제조 지시 및 공정 기록서-->
        <div id="makingTabContent" class="content workOrderProgressDetail tab-content active">
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
            </section>
        </div>
        <!--//제조 지시 및 공정 기록서-->
        <!--포장 지시 및 기록서-->
        <div id="fillingTabContent" class="content workOrderProgressFilling tab-content">
            <section class="radius">
                <div class="road_data">
                    <h6 class="doc_tit">포장 지시 및 기록서</h6>
                    <fieldset class="head">
                        <ul>
                            <li>지시일자 : <span id="f-order-date"></span></li>
                            <li>작업일자 : <span id="f-work-date"></span></li>
                        </ul>
                        <table>
                            <tr>
                                <th rowspan="2">결<br>재</th>
                                <th>담당</th>
                                <th>팀장</th>
                            </tr>
                            <tr>
                                <td class="box">&nbsp;</td>
                                <td class="box">&nbsp;</td>
                            </tr>
                        </table>
                    </fieldset>
                    <fieldset class="body">
                        <table class="requestTable">
                            <thead>
                                <tr>
                                    <th colspan="4">제품명</th>
                                    <th>제조번호<br>(LOT NO)</th>
                                    <th>지시수량<br>(ea)</th>
                                    <th>제조입고량<br>(kg)</th>
                                </tr>
                                <tr>
                                    <td colspan="4" class="name" id="f-product-name"></td>
                                    <td class="lot" id="f-lot"></td>
                                    <td id="f-order-qty-ea"></td>
                                    <td id="f-mfg-input-qty"></td>
                                </tr>
                            </thead>
                            <tbody id="f-items-tbody">
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
                                <!-- AJAX로 포장재 투입 행이 동적으로 삽입됩니다 -->
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
                                            <label class="radioButton"><input type="radio" name="f_item1" id="f-item1-fit" disabled value="적합"><i class="icon"></i><span>적합</span></label>
                                            <label class="radioButton"><input type="radio" name="f_item1" id="f-item1-unfit" disabled value="부적합"><i class="icon"></i><span>부적합</span></label>
                                        </div>
                                    </td>
                                    <td id="f-item1-reason"></td>
                                    <td id="f-item1-remark"></td>
                                </tr>
                                <tr>
                                    <td colspan="3" class="item">부적합 제품의 별도 보관 여부</td>
                                    <td>
                                        <div class="radioGroup">
                                            <label class="radioButton"><input type="radio" name="f_item2" id="f-item2-fit" disabled value="적합"><i class="icon"></i><span>적합</span></label>
                                            <label class="radioButton"><input type="radio" name="f_item2" id="f-item2-unfit" disabled value="부적합"><i class="icon"></i><span>부적합</span></label>
                                        </div>
                                    </td>
                                    <td id="f-item2-reason"></td>
                                    <td id="f-item2-remark"></td>
                                </tr>
                                <tr>
                                    <td colspan="3" class="item">사용된 부자재의 제품 사양과의 일치 여부</td>
                                    <td>
                                        <div class="radioGroup">
                                            <label class="radioButton"><input type="radio" name="f_item3" id="f-item3-fit" disabled value="적합"><i class="icon"></i><span>적합</span></label>
                                            <label class="radioButton"><input type="radio" name="f_item3" id="f-item3-unfit" disabled value="부적합"><i class="icon"></i><span>부적합</span></label>
                                        </div>
                                    </td>
                                    <td id="f-item3-reason"></td>
                                    <td id="f-item3-remark"></td>
                                </tr>
                                <tr>
                                    <td colspan="3" class="item">지시 수량과 생산수량의 일치 여부</td>
                                    <td>
                                        <div class="radioGroup">
                                            <label class="radioButton"><input type="radio" name="f_item4" id="f-item4-fit" disabled value="적합"><i class="icon"></i><span>적합</span></label>
                                            <label class="radioButton"><input type="radio" name="f_item4" id="f-item4-unfit" disabled value="부적합"><i class="icon"></i><span>부적합</span></label>
                                        </div>
                                    </td>
                                    <td id="f-item4-reason"></td>
                                    <td id="f-item4-remark"></td>
                                </tr>
                                <tr>
                                    <th rowspan="6">생산현황</th>
                                    <th>작업 시간</th>
                                    <td><span id="f-work-hours"></span> hr</td>
                                    <th rowspan="6">수율분석</th>
                                    <th>제조량</th>
                                    <td colspan="2"><span id="f-mfg-qty-kg"></span> kg</td>
                                </tr>
                                <tr>
                                    <th>작업 인원</th>
                                    <td><span id="f-work-person-count"></span> 명</td>
                                    <th>생산량</th>
                                    <td colspan="2"><span id="f-produced-qty-kg"></span> kg</td>
                                </tr>
                                <tr>
                                    <th>지시 수량</th>
                                    <td><span id="f-status-order-qty-ea"></span> ea</td>
                                    <th rowspan="2">수율</th>
                                    <td colspan="2" rowspan="2">
                                        <p class="per"><span id="f-yield-rate"></span> %</p>
                                        <p class="ex">(생산량/제조량*100)</p>
                                    </td>
                                </tr>
                                <tr>
                                    <th>생산 수량</th>
                                    <td><span id="f-production-qty"></span> ea</td>
                                </tr>
                                <tr>
                                    <th>폐기 수량</th>
                                    <td><span id="f-waste-qty"></span> ea</td>
                                    <th rowspan="2">불량율</th>
                                    <td colspan="2" rowspan="2">
                                        <p class="per"><span id="f-defect-rate"></span> %</p>
                                        <p class="ex">(폐기수량/생산수량*100)</p>
                                    </td>
                                </tr>
                                <tr>
                                    <th>출고 수량</th>
                                    <td><span id="f-release-qty"></span> ea</td>
                                </tr>
                                <tr class="last">
                                    <th>작성자</th>
                                    <td colspan="2" id="f-writer-name"></td>
                                    <th colspan="2">판정</th>
                                    <td colspan="2">
                                        <div class="radioGroup">
                                            <label class="radioButton"><input type="radio" name="f_verdict" id="f-verdict-fit" disabled value="적합"><i class="icon"></i><span>적합</span></label>
                                            <label class="radioButton"><input type="radio" name="f_verdict" id="f-verdict-unfit" disabled value="부적합"><i class="icon"></i><span>부적합</span></label>
                                        </div>
                                    </td>
                                </tr>
                            </tfoot>
                        </table>
                    </fieldset>
                </div>
            </section>
        </div>
        <!--포장 지시 및 기록서-->
        <div class="bottom_btns">
            <button type="button" id="backListBtn" class="Button iconButton list" data-width="180">목록</button>
            <button type="button" id="printBtn" class="Button iconButton print" data-width="180">인쇄</button>
            <!-- <button type="button" id="excelBtn" class="Button brdrGreen" data-width="180">엑셀저장</button> -->
            <button type="button" id="pdfBtn" class="Button iconButton pdf" data-width="180">PDF저장</button>
            <button type="button" id="deleteBtn" class="Button iconButton delete" data-width="180">삭제</button>
        </div>
    </div>
</div>

<script>
    let currentRequestId = "<%= requestIdStr != null ? requestIdStr : "" %>";
    let currentBatchNo = "";
    let currentProductName = "";
    let currentRequestDate = "";

    // 파일명(인쇄/엑셀/PDF 공통) 구성용 메타정보
    let fileMeta = { batchNo: "", expYYMMDD: "", productName: "", capacityDisplay: "" };

    function formatWithComma(value) {
        if (value === null || value === undefined || value === "") return "";
        let parts = value.toString().split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        return parts.join('.');
    }

    // ISO 날짜 문자열("2029-08-14") -> "290814"
    function formatExpYYMMDD(isoDateStr) {
        if (!isoDateStr) return "";
        let parts = isoDateStr.split('-');
        if (parts.length !== 3) return isoDateStr;
        return parts[0].slice(-2) + parts[1] + parts[2];
    }

    // ISO 날짜 문자열("2026-08-09") -> "2026년 08월 09일"
    function formatKoreanDate(isoDateStr) {
        if (!isoDateStr) return "";
        let datePart = isoDateStr.split(' ')[0].split('T')[0];
        let parts = datePart.split('-');
        if (parts.length !== 3) return isoDateStr;
        return parts[0] + "년 " + parts[1] + "월 " + parts[2] + "일";
    }

    // 파일명에 쓸 수 없는 문자 제거
    function sanitizeFileName(str) {
        return (str || "").replace(/[\\/:*?"<>|]/g, "").trim();
    }

    // 'lot+exp-제품명+용량' 파일명 베이스 생성 (예: M26I15-exp280914-스킨온유 미스트50mL)
    function buildFileNameBase() {
        let lot = fileMeta.batchNo || "NOLOT";
        let expPart = fileMeta.expYYMMDD ? ("exp" + fileMeta.expYYMMDD) : "";
        let prod = (fileMeta.productName || "") + (fileMeta.capacityDisplay || "");
        let base = lot + (expPart ? ("-" + expPart) : "") + "-" + prod;
        return sanitizeFileName(base);
    }

    $(document).ready(function () {
        if (!currentRequestId) {
            alert("유효하지 않은 접근입니다. (요청 ID 누락)");
            history.back();
            return;
        }

        loadAllData(currentRequestId);
        loadFillingData(currentRequestId);

        // ===================== 탭 전환 =====================
        $(document).on("click", ".tab-btn", function () {
            $(".tab-btn").removeClass("active");
            $(this).addClass("active");
            $(".tab-content").removeClass("active");
            $("#" + $(this).data("tab")).addClass("active");
        });

        // ===================== 하단 버튼 =====================
        $("#backListBtn").on("click", function () {
            location.href = "/app/workOrderProgress/workOrderProgressList.jsp";
        });

        $("#printBtn").on("click", function () {
            printBothTabsFitToA4();
        });

        $("#excelBtn").on("click", function () {
            exportToExcelTabs();
        });

        $("#pdfBtn").on("click", function () {
            exportToPdf();
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

    // ============================================================
    // TAB 1 : 제조 지시서 데이터 로드
    // ============================================================
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
                    currentRequestDate = req.request_date.substring(0, 10);
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

    function formatQtyText(qty, unit) {
        if (!qty || qty <= 0) return "";
        return formatWithComma(qty) + " " + (unit || "g");
    }

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
    }

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

            mk.items.forEach(function (it) {
                $('.lot-cell[data-row="' + it.item_row_id + '"]').text(it.lot_numbers || "");
                $('.qty-cell[data-row="' + it.item_row_id + '"]').text(formatQtyText(it.input_qty, it.input_unit));
            });
        }
    }

    // ============================================================
    // TAB 2 : 포장 지시 및 기록서 데이터 로드
    // ============================================================
    function loadFillingData(requestId) {
        $.ajax({
            url: "/app/workOrderProgress/common/getWorkOrderFillingData.jsp",
            type: "GET",
            data: { request_id: requestId },
            dataType: "json",
            success: function (res) {
                if (!res || !res.success) return;

                let base = res.base || {};
                let report = res.report || {};
                let items = res.items || [];

                // 제품명(용량) / 제조번호 / EXP / 지시일자 / 작업일자
                let capacityDisplay = "";
                if (base.product_capacity > 0) {
                    let capNum = (base.product_capacity === Math.floor(base.product_capacity))
                        ? base.product_capacity.toString() : base.product_capacity;
                    capacityDisplay = capNum + (base.capacity_unit || "");
                }
                let productDisplayName = (base.product_name || "") + (capacityDisplay ? ("(" + capacityDisplay + ")") : "");
                $("#f-product-name").text(productDisplayName);

                let expYYMMDD = base.due_date ? formatExpYYMMDD(base.due_date) : "";
                $("#f-lot").html((base.batch_no || "") + (expYYMMDD ? ("<br>EXP" + expYYMMDD) : ""));

                $("#f-order-date").text(base.request_date ? formatKoreanDate(base.request_date) : "");
                $("#f-work-date").text(report.work_date ? formatKoreanDate(report.work_date) : "");

                // 파일명(인쇄/엑셀/PDF 공통) 메타 저장
                fileMeta.batchNo = base.batch_no || "";
                fileMeta.expYYMMDD = expYYMMDD;
                fileMeta.productName = base.product_name || "";
                fileMeta.capacityDisplay = capacityDisplay;

                if (report) {
                    $("#f-order-qty-ea").text(report.order_qty_ea > 0 ? formatWithComma(report.order_qty_ea) : "");
                    $("#f-mfg-input-qty").text(report.mfg_input_qty > 0 ? formatWithComma(report.mfg_input_qty) : "");

                    setJudgeRow(1, report.item1_result, report.item1_reason, report.item1_remark);
                    setJudgeRow(2, report.item2_result, report.item2_reason, report.item2_remark);
                    setJudgeRow(3, report.item3_result, report.item3_reason, report.item3_remark);
                    setJudgeRow(4, report.item4_result, report.item4_reason, report.item4_remark);

                    $("#f-work-hours").text(report.work_hours > 0 ? formatWithComma(report.work_hours) : "");
                    $("#f-work-person-count").text(report.work_person_count > 0 ? report.work_person_count : "");
                    $("#f-mfg-qty-kg").text(report.mfg_qty_kg > 0 ? formatWithComma(report.mfg_qty_kg) : "");
                    $("#f-produced-qty-kg").text(report.produced_qty_kg > 0 ? formatWithComma(report.produced_qty_kg) : "");
                    $("#f-status-order-qty-ea").text(report.status_order_qty_ea > 0 ? formatWithComma(report.status_order_qty_ea) : "");
                    $("#f-production-qty").text(report.production_qty > 0 ? formatWithComma(report.production_qty) : "");
                    $("#f-waste-qty").text(report.waste_qty > 0 ? formatWithComma(report.waste_qty) : "");
                    $("#f-release-qty").text(report.release_qty > 0 ? formatWithComma(report.release_qty) : "");
                    $("#f-yield-rate").text(report.yield_rate > 0 ? formatWithComma(report.yield_rate) : "");
                    $("#f-defect-rate").text(report.defect_rate > 0 ? formatWithComma(report.defect_rate) : "");
                    $("#f-writer-name").text(report.writer_name || "");

                    let verdict = report.verdict || "적합";
                    $("#f-verdict-fit").prop("checked", verdict === "적합");
                    $("#f-verdict-unfit").prop("checked", verdict === "부적합");
                }

                // 포장재 투입 행
                let rowsHtml = "";
                items.forEach(function (it) {
                    let materialLabel = (it.item_name || "") + (it.subsidiary_type ? ("(" + it.subsidiary_type + ")") : "");
                    rowsHtml += '<tr>'
                        + '<td>' + (it.work_content || "") + '</td>'
                        + '<td>' + (it.machine_name || "") + '</td>'
                        + '<td colspan="2">' + materialLabel + '</td>'
                        + '<td>' + (it.out_qty > 0 ? formatWithComma(it.out_qty) + ' ea' : '') + '</td>'
                        + '<td>' + (it.worker_name || "") + '</td>'
                        + '<td>' + (it.defect_qty > 0 ? formatWithComma(it.defect_qty) + ' ea' : '') + '</td>'
                        + '</tr>';
                });
                $("#f-items-tbody").append(rowsHtml);
            },
            error: function () {
                console.log("포장 지시 및 기록서 데이터를 불러오지 못했습니다.");
            }
        });
    }

    // 항목1~4 : 라디오는 체크 상태만 반영(비활성 유지), 내용/비고는 텍스트로 표시
    function setJudgeRow(idx, result, reason, remark) {
        let isUnfit = (result === "부적합");
        $("#f-item" + idx + "-fit").prop("checked", !isUnfit);
        $("#f-item" + idx + "-unfit").prop("checked", isUnfit);
        $("#f-item" + idx + "-reason").text(isUnfit ? (reason || "") : "");
        $("#f-item" + idx + "-remark").text(remark || "");
    }

    // ============================================================
    // 인쇄 : 두 탭을 각각 A4 한 장씩 (요구사항 3)
    // ============================================================
    function printBothTabsFitToA4() {
        // 측정/인쇄을 위해 두 탭 모두 강제로 보이게 함 (인라인 스타일, 인쇄 후 원복)
        $(".tab-content").css("display", "block");
        $(".road_data").css("zoom", "1");

        $(".road_data").each(function () {
            let contentHeightPx = this.scrollHeight;
            let contentWidthPx = this.scrollWidth;
            const A4_HEIGHT_PX = Math.round((297 - 20) * 3.78);
            const A4_WIDTH_PX = Math.round((210 - 20) * 3.78);
            let scale = Math.min(A4_HEIGHT_PX / contentHeightPx, A4_WIDTH_PX / contentWidthPx, 1);
            if (scale < 1) $(this).css("zoom", scale);
        });

        window.print();

        function restore() {
            $(".road_data").css("zoom", "1");
            $(".tab-content").css("display", ""); // 사용자 CSS(active 탭 표시 규칙)로 복귀
        }
        window.onafterprint = restore;
        setTimeout(restore, 1000);
    }

    // ============================================================
    // 엑셀저장 : 제조 지시서 / 포장 지시 및 기록서 → 엑셀 시트(탭) 2개 (요구사항 4)
    // ============================================================
    function escXml(s) {
        return (s || "").toString().replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    }

    function buildSheetXML(sheetName, $table) {
        let xml = '<Worksheet ss:Name="' + escXml(sheetName) + '"><Table>';
        $table.find("tr").each(function () {
            xml += "<Row>";
            $(this).find("th, td").each(function () {
                let text = escXml($(this).text().trim());
                xml += '<Cell><Data ss:Type="String">' + text + "</Data></Cell>";
            });
            xml += "</Row>";
        });
        xml += "</Table></Worksheet>";
        return xml;
    }

    function exportToExcelTabs() {
        let excelXML = '<?xml version="1.0" encoding="UTF-8"?>'
            + '<?mso-application progid="Excel.Sheet"?>'
            + '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'
            + ' xmlns:o="urn:schemas-microsoft-com:office:office"'
            + ' xmlns:x="urn:schemas-microsoft-com:office:excel"'
            + ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'
            + ' xmlns:html="http://www.w3.org/TR/REC-html40">';

        excelXML += buildSheetXML("제조 지시서", $("#makingTabContent table.requestTable"));
        excelXML += buildSheetXML("포장 지시 및 기록서", $("#fillingTabContent table.requestTable"));

        excelXML += "</Workbook>";

        let blob = new Blob([excelXML], { type: "application/vnd.ms-excel;charset=utf-8;" });
        let link = document.createElement("a");
        link.href = URL.createObjectURL(blob);
        link.download = buildFileNameBase() + ".xls";
        link.click();
    }

    // ============================================================
    // PDF저장 : 두 탭을 각 1페이지씩 하나의 PDF로 저장 (요구사항 5)
    // ============================================================
    function pxToMm(px) {
        return px * 0.264583;
    }

    function exportToPdf() {
        if (typeof html2canvas === "undefined" || typeof window.jspdf === "undefined") {
            alert("PDF 라이브러리를 불러오지 못했습니다. 네트워크 상태를 확인해 주세요.");
            return;
        }

        $(".tab-content").css("display", "block");

        let $el1 = $("#makingTabContent .road_data");
        let $el2 = $("#fillingTabContent .road_data");
        let targets = [
            { el: $el1[0], w: $el1[0].offsetWidth, h: $el1[0].offsetHeight },
            { el: $el2[0], w: $el2[0].offsetWidth, h: $el2[0].offsetHeight }
        ];

        Promise.all(targets.map(function (t) { return html2canvas(t.el, { scale: 2, useCORS: true }); }))
            .then(function (canvases) {
                $(".tab-content").css("display", "");

                const { jsPDF } = window.jspdf;
                let pdf = new jsPDF("p", "mm", "a4");
                const pageW = 210, pageH = 297, margin = 10;
                const maxW = pageW - margin * 2;
                const maxH = pageH - margin * 2;

                canvases.forEach(function (canvas, idx) {
                    let imgData = canvas.toDataURL("image/png");
                    let wMm = pxToMm(targets[idx].w);
                    let hMm = pxToMm(targets[idx].h);
                    let scale = Math.min(maxW / wMm, maxH / hMm, 1);
                    let drawW = wMm * scale;
                    let drawH = hMm * scale;

                    if (idx > 0) pdf.addPage();
                    pdf.addImage(imgData, "PNG", margin, margin, drawW, drawH);
                });

                pdf.save(buildFileNameBase() + ".pdf");
            })
            .catch(function (err) {
                $(".tab-content").css("display", "");
                alert("PDF 생성 중 오류가 발생했습니다.");
                console.error(err);
            });
    }
</script>
<jsp:include page="/app/include/FooterDocType.jsp" />
