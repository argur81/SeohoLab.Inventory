<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String requestIdStr = request.getParameter("request_id");
%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<style>
    /* 인쇄 시 표(road_data) 영역만 출력 */
    @media print {
        body * { visibility: hidden; }
        .road_data, .road_data * { visibility: visible; }
        .road_data { position: absolute; left: 0; top: 0; width: 100%; }
        #loadingOverlay, .top_btn, .bottom_btns, header, .delExtraRowBtn, .no-print { display: none !important; }

        /* input/select를 테두리 없는 순수 텍스트처럼 인쇄 (값만 보이게) */
        .road_data input.inputText,
        .road_data input[type="date"],
        .road_data select.og_select {
            border: none !important;
            background: transparent !important;
            box-shadow: none !important;
            padding: 0 !important;
            margin: 0 !important;
            -webkit-appearance: none;
            appearance: none;
            color: #000 !important;
            font-size: inherit !important;
        }
    }
    @page {
        size: A4;
        margin: 10mm;
    }
    #loadingOverlay {
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(255,255,255,1); z-index: 9999;
        display: flex; flex-direction: column; justify-content: center; align-items: center;
    }
    .spinner {
        width: 50px; height: 50px; border: 5px solid #f3f3f3; border-top: 5px solid #3498db;
        border-radius: 50%; animation: spin 1s linear infinite;
    }
    .loading_text { margin-top: 15px; font-weight: bold; color: #333; font-size: 14px; }
    @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    tr.extra-row td { background: #fffceb; }
    .delExtraRowBtn { padding: 4px 8px; font-size: 12px; }
</style>
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
                    <p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>진행현황</b><i><img src="/images/svg/location_arrow.svg"></i>제조중</b>
                </h5>
            </div>
            <section class="radius">
                <form id="makingForm">
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
                                <td colspan="2"><input type="text" id="batch_no" name="batch_no" class="inputText" placeholder="자동생성 (제조완료 시 확정됩니다)" title="제조완료 버튼을 누르면 완료일 기준으로 확정됩니다"></td>
                                <td colspan="3">
                                    <div class="yy-mm-dd"><input type="date" id="due_date" name="due_date" class="inputText"><span>까지</span></div>
                                </td>
                                <th>제조지시자</th>
                                <td id="load-manager-name"></td>
                                <th>제조자</th>
                                <td><input type="text" id="maker_name" name="maker_name" class="inputText" value="윤철우"></td>
                            </tr>
                            <tr>
                                <th>제조기기</th>
                                <td colspan="5" id="load-machine"></td>
                                <th>제조지시일</th>
                                <td id="load-request-date"></td>
                                <th>제조일자</th>
                                <td><input type="date" id="mfg_date" name="mfg_date" class="inputText"></td>
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
                                <th>비고 / 관리</th>
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
                                <td colspan="3"><input type="text" id="appearance_result" name="appearance_result" class="inputText"></td>
                                <th colspan="2">실제제조량</th>
                                <td colspan="2">
                                    <div class="unit"><input type="text" id="actual_qty" name="actual_qty" class="inputText" readonly><i>kg</i></div>
                                </td>
                            </tr>
                            <tr>
                                <th>향취</th>
                                <td colspan="2" id="load-scent"></td>
                                <td colspan="3"><input type="text" id="scent_result" name="scent_result" class="inputText"></td>
                                <th colspan="2">제조수율</th>
                                <td colspan="2"><input type="text" id="yield_rate_actual" name="yield_rate_actual" class="inputText" placeholder="숫자 입력"></td>
                            </tr>
                            <tr>
                                <th>비중</th>
                                <td colspan="2" id="load-specific-gravity"></td>
                                <td colspan="3"><input type="text" id="specific_gravity_result" name="specific_gravity_result" class="inputText"></td>
                                <th colspan="2">제조수율기준</th>
                                <td colspan="2" id="load-yield-standard"></td>
                            </tr>
                            <tr>
                                <th>ph</th>
                                <td colspan="2" id="load-ph"></td>
                                <td colspan="3"><input type="text" id="ph_result" name="ph_result" class="inputText"></td>
                                <td colspan="4" class="al-center">제조수율 = (실제제조량/이론제조량) * 100</td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                </form>

                <!-- 원료 Lot 선택 팝업 (usedRegist.jsp / releaseRegist.jsp 와 동일한 UX) -->
                <div class="layer_popup" id="itemLotPopup" style="display: none;">
                    <div class="pop_data people_pop" data-width="860">
                        <div class="head">
                            <h6 id="lotPopupTitle">원료 Lot 리스트</h6>
                            <button type="button" class="close btn_close_pop" title="닫기"><img src="/images/svg/popup_close.svg"></button>
                        </div>
                        <div class="body">
                            <ul id="lot_list_ul"></ul>
                        </div>
                        <div class="bottom_btns">
                            <button type="button" id="btn_item_reset_lots" class="Button bgGray" data-width="180">초기화</button>
                            <button type="button" id="btn_item_apply_lots" class="Button bgBlue" data-width="180">적용</button>
                        </div>
                    </div>
                </div>
                <!-- //Lot 선택 팝업 -->

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

<script>
    let currentRequestId = "<%= requestIdStr != null ? requestIdStr : "" %>";

    // 원료 행별 Lot 사용 데이터 (item_row_id 기준으로 보관)
    // { lotNumbers: "L1, L2", inputQty: 1234.5, inputUnit: "g", lots: [{lot_number, t, kg, g, mg}, ...] }
    let rowLotData = {};

    // 행별 메타정보 (원료명 / 추가행 여부) - 지시서 원료 + 제조중 추가원료 공통 관리
    let rowMeta = {}; // { [rowId]: { rawMaterialName, isExtra } }

    let totalOriginalRows = 0; // 지시서 원료 행 개수
    let nextExtraRowId = 0;    // 다음에 추가할 행 번호

    // 현재 팝업이 열려있는 행 정보
    let activePopupRowId = null;
    let wasFullUseClicked = false; // 팝업 세션 동안 [전체사용]을 눌렀는지 여부 (조건4: g기준 강제)

    const unitToGram = { t: 1000000, kg: 1000, g: 1, mg: 0.001 };

    function formatWithComma(value) {
        if (value === null || value === undefined || value === "") return "";
        let parts = value.toString().split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        return parts.join('.');
    }

    function parseNum(str) {
        if (!str) return 0;
        let v = parseFloat(str.toString().replace(/,/g, ''));
        return isNaN(v) ? 0 : v;
    }

    function formatNumberAuto(num) {
        if (num >= 1000000) {
            return new Intl.NumberFormat('en-US', { notation: 'compact', maximumFractionDigits: 1 }).format(num);
        }
        return new Intl.NumberFormat('en-US').format(num);
    }

    // 제조번호(Lot) 자동생성: M + 연도2자리 + 월코드(A=1월 ~ L=12월) + 일자2자리
    // 예) 2026년 8월 15일 -> M26H15
    const MONTH_LETTERS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'];
    function generateBatchNo(dateObj) {
        let yy = String(dateObj.getFullYear()).slice(-2);
        let monthLetter = MONTH_LETTERS[dateObj.getMonth()]; // getMonth()는 0(1월)~11(12월)
        let dd = String(dateObj.getDate()).padStart(2, '0');
        return 'M' + yy + monthLetter + dd;
    }

    // 인쇄 시 표(.road_data) 실제 높이를 측정해 A4 한 장(여백 10mm 기준)에 들어가도록 자동 축소
    // ※ transform:scale은 화면에만 축소되어 보이고 인쇄 페이지분할 계산에는 반영되지 않으므로
    //    실제 레이아웃 크기 자체를 줄이는 zoom 속성을 사용한다 (Chrome/Edge 기준 확실히 동작)
    function printFitToA4() {
        let $road = $(".road_data");

        // 측정 전 기존 축소를 초기화
        $road.css("zoom", "1");

        let contentHeightPx = $road[0].scrollHeight;
        let contentWidthPx = $road[0].scrollWidth;

        // A4(210mm x 297mm), 여백 10mm 가정, 96dpi 환산(1mm ≈ 3.78px)
        const A4_HEIGHT_PX = Math.round((297 - 20) * 3.78); // ≈ 1047px
        const A4_WIDTH_PX = Math.round((210 - 20) * 3.78);  // ≈ 718px

        let scaleH = A4_HEIGHT_PX / contentHeightPx;
        let scaleW = A4_WIDTH_PX / contentWidthPx;
        let scale = Math.min(scaleH, scaleW, 1); // 원본보다 확대는 하지 않음

        if (scale < 1) {
            $road.css("zoom", scale);
        }

        window.print();

        // 인쇄(또는 취소) 후 화면상 배율 원상복구
        let restore = function () {
            $road.css("zoom", "1");
        };
        window.onafterprint = restore;
        setTimeout(restore, 1000); // onafterprint 미지원 브라우저 대비 fallback
    }

    $(document).ready(function () {
        if (!currentRequestId) {
            alert("유효하지 않은 접근입니다. (요청 ID 누락)");
            history.back();
            return;
        }

        loadOrderData(currentRequestId);

        // ===================== 하단 버튼 =====================
        $("#backListBtn").on("click", function () {
            location.href = "/app/workOrderProgress/workOrderProgressList.jsp";
        });

        $("#printBtn").on("click", function () {
            printFitToA4();
        });

        $("#deleteBtn").on("click", function () {
            if (!confirm("정말 이 제조요청을 삭제하시겠습니까?")) return;
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

        $("#completedProgressBtn").on("click", function () {
            // 제조번호는 시작일이 아니라 "완료된 날짜" 기준으로 확정한다 (제조가 여러 날에 걸칠 수 있으므로)
            let confirmedBatchNo = generateBatchNo(new Date());
            $("#batch_no").val(confirmedBatchNo);

            if (!confirm("제조를 완료하고 승인요청 하시겠습니까?\n\n확정 제조번호: " + confirmedBatchNo)) return;

            let $btn = $(this);
            $btn.prop("disabled", true);

            // 마지막 상태를 먼저 저장한 뒤 승인요청 상태로 전환 (재고 차감은 승인 단계에서 처리)
            saveMakingData(function () {
                $.ajax({
                    url: "workOrderProgressSubmitApprovalAction.jsp",
                    type: "POST",
                    data: { request_id: currentRequestId },
                    dataType: "json",
                    success: function (res) {
                        if (res && res.success) {
                            location.href = "/app/workOrderProgress/workOrderProgressApproval.jsp?request_id=" + currentRequestId;
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
        });

        // ===================== 원료 행 추가 (pH 조정 등) =====================
        $(document).on("click", "#addExtraRowBtn", function () {
            addExtraRow(null);
        });

        $(document).on("click", ".delExtraRowBtn", function () {
            let rowId = parseInt($(this).data("row"));
            if (!confirm("이 원료 행을 삭제하시겠습니까?")) return;

            $('tr[data-row-id="' + rowId + '"]').remove();
            delete rowLotData[rowId];
            delete rowMeta[rowId];
            recalcActualQty();
        });

        // ===================== Lot 팝업 =====================
        $(document).on("click", ".lot-input", function () {
            let $this = $(this);
            let rowId = parseInt($this.data("row"));
            let meta = rowMeta[rowId];

            if (!meta || !meta.rawMaterialName) {
                alert("원료명을 먼저 입력(선택)해 주세요.");
                return;
            }

            activePopupRowId = rowId;
            wasFullUseClicked = false;
            openLotPopup(rowId, meta.rawMaterialName);
        });

        $(document).on("click", "#itemLotPopup .btn_close_pop", function () {
            $("#itemLotPopup").hide();
        });

        // 전체사용
        $(document).on("click", ".btn_all_use", function () {
            let $li = $(this).closest("li");
            let t = $(this).attr("data-t");
            let kg = $(this).attr("data-kg");
            let g = $(this).attr("data-g");
            let mg = $(this).attr("data-mg");

            $li.find(".unit_t input").val(Number(t) > 0 ? Number(t).toLocaleString('en-US') : "");
            $li.find(".unit_kg input").val(Number(kg) > 0 ? Number(kg).toLocaleString('en-US') : "");
            $li.find(".unit_g input").val(Number(g) > 0 ? Number(g).toLocaleString('en-US') : "");
            $li.find(".unit_mg input").val(Number(mg) > 0 ? Number(mg).toLocaleString('en-US') : "");

            wasFullUseClicked = true; // 조건4: 전체사용 선택 시 g기준으로 표기
        });

        // 팝업 내 숫자입력 콤마 포맷
        $(document).on('input', '#itemLotPopup input[inputmode="decimal"]', function () {
            let value = $(this).val().replace(/[^0-9.]/g, '');
            $(this).val(formatWithComma(value));
        });

        // 초기화 버튼: 팝업에 표시된 모든 Lot의 입력값을 비움 (처음부터 다시 선택 가능)
        $(document).on("click", "#btn_item_reset_lots", function () {
            $("#itemLotPopup #lot_list_ul input").val("");
            wasFullUseClicked = false;
        });

        // 적용 버튼
        $(document).on("click", "#btn_item_apply_lots", function () {
            if (activePopupRowId === null) { $("#itemLotPopup").hide(); return; }

            let selectedLots = [];
            let kgEnteredSum = 0, gEnteredSum = 0, tSum = 0, mgSum = 0;

            $("#itemLotPopup #lot_list_ul li").each(function () {
                let $li = $(this);
                let lotNumber = $li.find(".lot dd").text().trim();
                let t = parseNum($li.find(".unit_t input").val());
                let kg = parseNum($li.find(".unit_kg input").val());
                let g = parseNum($li.find(".unit_g input").val());
                let mg = parseNum($li.find(".unit_mg input").val());

                if (t > 0 || kg > 0 || g > 0 || mg > 0) {
                    selectedLots.push({ lot_number: lotNumber, t: t, kg: kg, g: g, mg: mg });
                    tSum += t; kgEnteredSum += kg; gEnteredSum += g; mgSum += mg;
                }
            });

            if (selectedLots.length === 0) {
                // 아무 값도 없이 적용 -> 해당 행의 Lot/투입량을 완전히 비움 (초기화 후 재적용 케이스)
                delete rowLotData[activePopupRowId];
                let $rowClear = $('tr[data-row-id="' + activePopupRowId + '"]');
                $rowClear.find(".lot-input").val("");
                $rowClear.find(".input-qty").val("");
                recalcActualQty();
                $("#itemLotPopup").hide();
                activePopupRowId = null;
                return;
            }

            let totalGrams = (tSum * unitToGram.t) + (kgEnteredSum * unitToGram.kg) + gEnteredSum + (mgSum * unitToGram.mg);

            // ===== 투입량 단위 결정 로직 =====
            // 조건4: 전체사용을 한번이라도 눌렀다면 g기준
            // 조건2: kg란에만 입력했으면 kg기준, g란에만 입력했으면 g기준
            // 그 외(혼용/애매) : g기준 (기본값)
            let unit, value;
            if (wasFullUseClicked) {
                unit = "g"; value = totalGrams;
            } else if (kgEnteredSum > 0 && gEnteredSum === 0 && tSum === 0 && mgSum === 0) {
                unit = "kg"; value = kgEnteredSum;
            } else if (gEnteredSum > 0 && kgEnteredSum === 0 && tSum === 0 && mgSum === 0) {
                unit = "g"; value = gEnteredSum;
            } else {
                unit = "g"; value = totalGrams;
            }

            // 조건1: Lot 2개 이상이면 콤마로 구분
            let lotNumbersStr = selectedLots.map(function (l) { return l.lot_number; }).join(', ');

            rowLotData[activePopupRowId] = {
                lotNumbers: lotNumbersStr,
                inputQty: value,
                inputUnit: unit,
                lots: selectedLots
            };

            // 화면 반영
            let $row = $('tr[data-row-id="' + activePopupRowId + '"]');
            $row.find(".lot-input").val(lotNumbersStr);
            $row.find(".input-qty").val(formatWithComma(Number(value.toFixed(4))));
            $row.find(".input-unit").val(unit);

            recalcActualQty();

            $("#itemLotPopup").hide();
            activePopupRowId = null;
        });

        // ===================== 자동저장 (5초) =====================
        setInterval(function () { saveMakingData(); }, 5000);
    });

    // 지시서 원본 데이터 로드 (마스터/원료목록/제조방법) + 이전 저장된 제조중 데이터 로드
    function loadOrderData(requestId) {
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
                $("#load-manager-name").text(m.manager_name || "");
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

                // 저장되어 있던 제조중 데이터 불러와서 복원
                $.ajax({
                    url: "getWorkOrderMakingData.jsp",
                    type: "GET",
                    data: { request_id: requestId },
                    dataType: "json",
                    success: function (mk) {
                        applyMakingData(mk);
                        $('#loadingOverlay').fadeOut(500);
                    },
                    error: function () {
                        $('#loadingOverlay').fadeOut(500);
                    }
                });
            },
            error: function () {
                alert("데이터를 가져오는 중 오류가 발생했습니다.");
                $('#loadingOverlay').fadeOut(500);
            }
        });
    }

    // 원료 목록 테이블 렌더링 (지시서 원료, 상/제조방법/비고는 rowspan 처리)
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

            rowMeta[rowNum] = { rawMaterialName: item.raw_material_name || "", isExtra: false };

            let safeName = (item.raw_material_name || '').replace(/"/g, '&quot;');

            let lotCell = '<td><input type="text" class="inputText lot-input" data-row="' + rowNum + '" placeholder="클릭하여 Lot 선택" readonly></td>';
            let qtyCell = '<td><div class="input_enter">'
                + '<input type="text" class="inputText input-qty" data-row="' + rowNum + '" readonly>'
                + '<select class="og_select input-unit" data-row="' + rowNum + '" disabled>'
                + '<option value="kg">kg</option><option value="g">g</option>'
                + '</select></div></td>';

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

        // 마지막 행: [원료 행 추가] 버튼 (인쇄 시에는 숨김)
        tbodyHtml += '<tr id="addRowTr" class="no-print">'
            + '<td colspan="10" class="al-center">'
            + '<button type="button" id="addExtraRowBtn" class="Button">원료 행 추가 (pH 조정 등)</button>'
            + '</td></tr>';

        $("#load-items-tbody").html(tbodyHtml);
        $("#load-total-pct").text(formatWithComma(Math.round(totalPct)) + " %");
        $("#load-total-kg").text(formatWithComma(Math.round(totalKg)) + " kg");
        $("#load-total-g").text(formatWithComma(Math.round(totalG)) + " g");

        totalOriginalRows = items.length;
        nextExtraRowId = totalOriginalRows;
    }

    // 제조 중 원료 행 추가 (pH 조정 등). prefill이 있으면 저장된 값 복원용으로 사용.
    function addExtraRow(prefill) {
        nextExtraRowId++;
        let rowId = nextExtraRowId;

        rowMeta[rowId] = { rawMaterialName: prefill ? prefill.rawMaterialName : "", isExtra: true };

        let nameValue = prefill ? (prefill.rawMaterialName || '') : '';
        let noteValue = prefill ? (prefill.note || '') : '';

        let rowHtml = '<tr data-row-id="' + rowId + '" class="extra-row">'
            + '<td class="al-center">-</td>'
            + '<td class="al-center">' + rowId + '</td>'
            + '<td><input type="text" class="inputText item-autocomplete-extra" data-row="' + rowId + '" placeholder="원료명 입력 (자동완성)" value="' + nameValue.replace(/"/g, '&quot;') + '"></td>'
            + '<td><input type="text" class="inputText lot-input" data-row="' + rowId + '" placeholder="원료명 먼저 입력" readonly></td>'
            + '<td class="al-center">-</td>'
            + '<td class="al-center">-</td>'
            + '<td class="al-center">-</td>'
            + '<td><div class="input_enter">'
            +   '<input type="text" class="inputText input-qty" data-row="' + rowId + '" readonly>'
            +   '<select class="og_select input-unit" data-row="' + rowId + '" disabled>'
            +     '<option value="kg">kg</option><option value="g">g</option>'
            +   '</select></div></td>'
            + '<td>-</td>'
            + '<td><input type="text" class="inputText extra-note" data-row="' + rowId + '" placeholder="추가 사유 (예: pH 조정)" value="' + noteValue.replace(/"/g, '&quot;') + '">'
            +   ' <button type="button" class="delExtraRowBtn" data-row="' + rowId + '">삭제</button></td>'
            + '</tr>';

        // [원료 행 추가] 버튼이 있는 tr(#addRowTr) 바로 위에 새 행을 삽입
        if ($('#addRowTr').length > 0) {
            $('#addRowTr').before(rowHtml);
        } else {
            $("#load-items-tbody").append(rowHtml);
        }
        initExtraAutocomplete($('tr[data-row-id="' + rowId + '"] .item-autocomplete-extra'));

        return rowId;
    }

    // 추가원료 행의 원료명 자동완성 (workOrder 폴더의 기존 엔드포인트 재사용)
    function initExtraAutocomplete($input) {
        $input.autocomplete({
            source: "/app/workOrder/getItemAutoComplete.jsp",
            minLength: 1,
            select: function (event, ui) {
                let rowId = parseInt($(this).data("row"));
                rowMeta[rowId] = rowMeta[rowId] || {};
                rowMeta[rowId].rawMaterialName = ui.item.value;
                rowMeta[rowId].isExtra = true;

                $(this).val(ui.item.value);

                // 원료명이 바뀌면 이미 선택해둔 Lot 정보는 초기화 (다른 원료의 Lot을 쓸 수 없으므로)
                delete rowLotData[rowId];
                let $row = $('tr[data-row-id="' + rowId + '"]');
                $row.find(".lot-input").val("");
                $row.find(".input-qty").val("");
                recalcActualQty();

                return false;
            }
        });
    }

    // 저장되어 있던 제조중 데이터를 화면에 복원 (지시서 원료 + 추가원료 모두)
    function applyMakingData(mk) {
        if (mk && mk.making) {
            let hdr = mk.making;
            $("#batch_no").val(hdr.batch_no || "");
            $("#due_date").val(hdr.due_date || "");
            $("#maker_name").val(hdr.maker_name || "윤철우");
            $("#mfg_date").val(hdr.mfg_date || "");
            $("#appearance_result").val(hdr.appearance_result || "");
            $("#scent_result").val(hdr.scent_result || "");
            $("#specific_gravity_result").val(hdr.specific_gravity_result || "");
            $("#ph_result").val(hdr.ph_result || "");
            $("#yield_rate_actual").val(hdr.yield_rate_actual > 0 ? hdr.yield_rate_actual : "");
        }

        // 저장된 제조번호가 없으면(최초 진입) 오늘 날짜 기준으로 임시 자동생성
        // (제조완료 시점 날짜로 다시 확정되므로 여기서는 임시값)
        if (!$("#batch_no").val()) {
            $("#batch_no").val(generateBatchNo(new Date()));
        }

        if (mk && mk.items && mk.items.length > 0) {
            // 1) 추가원료 행부터 먼저 화면에 만들어 둔다 (그래야 아래에서 tr을 찾을 수 있음)
            mk.items.forEach(function (it) {
                if (it.is_extra === 1) {
                    let rowId = addExtraRow({ rawMaterialName: it.raw_material_name, note: it.note });
                    // addExtraRow가 새 번호를 발급하므로, 저장된 item_row_id와 매핑을 다시 맞춰준다
                    if (rowId !== it.item_row_id) {
                        it._resolvedRowId = rowId;
                    } else {
                        it._resolvedRowId = it.item_row_id;
                    }
                }
            });

            // 2) 지시서 원료 + 추가원료 모두에 Lot/투입량 값 적용
            mk.items.forEach(function (it) {
                let rowId = (it.is_extra === 1) ? it._resolvedRowId : it.item_row_id;

                rowLotData[rowId] = {
                    lotNumbers: it.lot_numbers || "",
                    inputQty: it.input_qty || 0,
                    inputUnit: it.input_unit || "g",
                    lots: (it.lots || []).map(function (l) {
                        return { lot_number: l.lot_number, t: l.t, kg: l.kg, g: l.g, mg: l.mg };
                    })
                };

                let $row = $('tr[data-row-id="' + rowId + '"]');
                $row.find(".lot-input").val(it.lot_numbers || "");
                $row.find(".input-qty").val(it.input_qty > 0 ? formatWithComma(it.input_qty) : "");
                $row.find(".input-unit").val(it.input_unit || "g");
            });
        }

        recalcActualQty();
    }

    // Lot 팝업 열기 (getItemLots.jsp 재사용, 이전 입력값 있으면 복원)
    function openLotPopup(rowId, itemName) {
        $("#lotPopupTitle").text(itemName + " - Lot 선택");

        $.ajax({
            url: "/app/totalRegist/getItemLots.jsp",
            type: "GET",
            data: { item_name: itemName, category: "RAW" },
            dataType: "json",
            success: function (lotList) {
                let $ul = $("#lot_list_ul");
                $ul.empty();

                if (!lotList || lotList.length === 0) {
                    $ul.html('<li style="text-align:center; padding: 15px;">등록된 Lot이 없습니다.</li>');
                } else {
                    let saved = rowLotData[rowId];
                    let savedMap = {};
                    if (saved && saved.lots) {
                        saved.lots.forEach(function (l) { savedMap[l.lot_number] = l; });
                    }

                    $.each(lotList, function (idx, item) {
                        let rawT = item.stock_qty_t || 0;
                        let rawKg = item.stock_qty_kg || 0;
                        let rawG = item.stock_qty_g || 0;
                        let rawMg = item.stock_qty_mg || 0;

                        let t = formatNumberAuto(rawT);
                        let kg = formatNumberAuto(rawKg);
                        let g = formatNumberAuto(rawG);
                        let mg = formatNumberAuto(rawMg);

                        let sv = savedMap[item.lot_number] || { t: '', kg: '', g: '', mg: '' };
                        let svT = sv.t ? sv.t : '';
                        let svKg = sv.kg ? sv.kg : '';
                        let svG = sv.g ? sv.g : '';
                        let svMg = sv.mg ? sv.mg : '';

                        let html = '<li>'
                            + '<dl class="lot"><dt>Lot번호</dt><dd>' + item.lot_number + '</dd></dl>'
                            + '<dl class="stock"><dt>현재재고</dt><dd>'
                            + '<i>' + t + '</i> t / <i>' + kg + '</i> kg / <i>' + g + '</i> g / <i>' + mg + '</i> mg'
                            + '</dd></dl>'
                            + '<dl class="volume">'
                            + '<dt>사용량 <button type="button" class="btn_all_use"'
                            + ' data-t="' + rawT + '" data-kg="' + rawKg + '" data-g="' + rawG + '" data-mg="' + rawMg + '">전체사용</button></dt>'
                            + '<dd>'
                            + '<div class="unit_t"><input type="text" class="inputText" data-unit="t" value="' + (svT || '') + '" inputmode="decimal"><i>t</i></div>'
                            + '<div class="unit_kg"><input type="text" class="inputText" data-unit="kg" value="' + (svKg || '') + '" inputmode="decimal"><i>kg</i></div>'
                            + '<div class="unit_g"><input type="text" class="inputText" data-unit="g" value="' + (svG || '') + '" inputmode="decimal"><i>g</i></div>'
                            + '<div class="unit_mg"><input type="text" class="inputText" data-unit="mg" value="' + (svMg || '') + '" inputmode="decimal"><i>mg</i></div>'
                            + '</dd></dl>'
                            + '</li>';
                        $ul.append(html);
                    });
                }
                $("#itemLotPopup").show();
            },
            error: function () {
                alert("Lot 목록을 불러오는 중 오류가 발생했습니다.");
            }
        });
    }

    // 실제제조량 실시간 계산 (모든 행의 투입량을 kg 기준으로 합산 - 지시서 원료 + 추가원료 모두 포함)
    function recalcActualQty() {
        let totalKg = 0;
        Object.keys(rowLotData).forEach(function (rowId) {
            let d = rowLotData[rowId];
            if (!d) return;
            totalKg += (d.inputUnit === 'kg') ? d.inputQty : (d.inputQty / 1000);
        });
        $("#actual_qty").val(formatWithComma(Number(totalKg.toFixed(4))));
    }

    // 5초 자동저장 (조용히 처리, 완료 콜백 선택적)
    function saveMakingData(callback) {
        if (!currentRequestId) return;

        // 동적 hidden input 정리 후 재생성
        $("#makingForm .dynamic-save-input").remove();

        let $form = $("#makingForm");
        let idx = 0;
        Object.keys(rowLotData).forEach(function (rowId) {
            let d = rowLotData[rowId];
            if (!d) return;
            let meta = rowMeta[rowId] || {};
            let noteVal = meta.isExtra ? $('tr[data-row-id="' + rowId + '"] .extra-note').val() : '';

            $form.append('<input type="hidden" class="dynamic-save-input" name="itemRows[' + idx + '].item_row_id" value="' + rowId + '">');
            $form.append('<input type="hidden" class="dynamic-save-input" name="itemRows[' + idx + '].raw_material_name" value="' + (meta.rawMaterialName || '').replace(/"/g, '&quot;') + '">');
            $form.append('<input type="hidden" class="dynamic-save-input" name="itemRows[' + idx + '].is_extra" value="' + (meta.isExtra ? '1' : '0') + '">');
            $form.append('<input type="hidden" class="dynamic-save-input" name="itemRows[' + idx + '].lot_numbers" value="' + (d.lotNumbers || '').replace(/"/g, '&quot;') + '">');
            $form.append('<input type="hidden" class="dynamic-save-input" name="itemRows[' + idx + '].input_qty" value="' + d.inputQty + '">');
            $form.append('<input type="hidden" class="dynamic-save-input" name="itemRows[' + idx + '].input_unit" value="' + d.inputUnit + '">');
            $form.append('<input type="hidden" class="dynamic-save-input" name="itemRows[' + idx + '].note" value="' + (noteVal || '').replace(/"/g, '&quot;') + '">');
            idx++;
        });

        let lIdx = 0;
        Object.keys(rowLotData).forEach(function (rowId) {
            let d = rowLotData[rowId];
            if (!d || !d.lots) return;
            let meta = rowMeta[rowId] || {};
            d.lots.forEach(function (l) {
                $form.append('<input type="hidden" class="dynamic-save-input" name="lotDetails[' + lIdx + '].item_row_id" value="' + rowId + '">');
                $form.append('<input type="hidden" class="dynamic-save-input" name="lotDetails[' + lIdx + '].raw_material_name" value="' + (meta.rawMaterialName || '').replace(/"/g, '&quot;') + '">');
                $form.append('<input type="hidden" class="dynamic-save-input" name="lotDetails[' + lIdx + '].lot_number" value="' + l.lot_number + '">');
                $form.append('<input type="hidden" class="dynamic-save-input" name="lotDetails[' + lIdx + '].t" value="' + (l.t || 0) + '">');
                $form.append('<input type="hidden" class="dynamic-save-input" name="lotDetails[' + lIdx + '].kg" value="' + (l.kg || 0) + '">');
                $form.append('<input type="hidden" class="dynamic-save-input" name="lotDetails[' + lIdx + '].g" value="' + (l.g || 0) + '">');
                $form.append('<input type="hidden" class="dynamic-save-input" name="lotDetails[' + lIdx + '].mg" value="' + (l.mg || 0) + '">');
                lIdx++;
            });
        });

        let payload = $form.serialize() + "&request_id=" + encodeURIComponent(currentRequestId)
            + "&actual_qty=" + encodeURIComponent(parseNum($("#actual_qty").val()));

        $.ajax({
            url: "workOrderProgressMakingSaveAction.jsp",
            type: "POST",
            data: payload,
            dataType: "json",
            success: function () {
                if (typeof callback === 'function') callback();
            },
            error: function () {
                console.log("자동저장 실패 (다음 주기에 재시도)");
                if (typeof callback === 'function') callback();
            }
        });
    }
</script>
<jsp:include page="/app/include/FooterDocType.jsp" />
