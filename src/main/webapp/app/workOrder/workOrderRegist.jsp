<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <!-- jQuery UI 스타일 및 스크립트 (자동완성용) -->
    <link rel="stylesheet" href="//code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
    <script src="//code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>

    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content workOrderList">
                <div class="title_set">
                    <h5 class="page_tit"><p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>지시서 관리</b><i><img src="/images/svg/location_arrow.svg"></i>신규등록</h5>
                </div>
                <form id="regForm" method="post" action="workOrderRegistAction.jsp">
                    <section class="radius">
                        <dl class="w50">
                            <dt>제품명</dt>
                            <dd><input type="text" name="product_name" class="inputText" placeholder="제품명 입력" required></dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조지시량</dt>
                            <dd class="has_input-select">
                                <input type="text" name="target_qty" class="inputText top-target-qty" inputmode="decimal" value="0">
                                <select name="target_unit" class="og_select top-target-unit">
                                    <option selected>kg</option>
                                    <option>g</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조지시자</dt>
                            <dd><input type="text" name="manager_name" class="inputText" value="박소희"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조기기</dt>
                            <dd>
                                <select name="machine" class="og_select">
                                    <option selected>AGI Mixer</option>
                                    <option>Homo Mixer</option>
                                    <option>AGI Mixer, Homo Mixer</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>성상</dt>
                            <dd><input type="text" name="appearance" class="inputText"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>향취</dt>
                            <dd><input type="text" name="scent" class="inputText"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>비중</dt>
                            <dd><input type="text" name="specific_gravity" class="inputText"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>pH</dt>
                            <dd><input type="text" name="ph" class="inputText"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>이론제조량</dt>
                            <dd class="has_input-select">
                                <input type="text" name="theor_qty" class="inputText" inputmode="decimal">
                                <select name="theor_unit" class="og_select">
                                    <option selected>kg</option>
                                    <option>g</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조수율</dt>
                            <dd><input type="text" name="yield_rate" class="inputText" placeholder="제조수율 = (실제제조량/이론제조량) * 100"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조수율 기준</dt>
                            <dd><input type="text" name="yield_standard" class="inputText"></dd>
                        </dl>
                    </section>
                    <section class="radius">
                        <table class="order_table">
                            <colgroup>
                                <col width="100">
                                <col width="auto">
                                <col width="180">
                                <col width="170">
                                <col width="170">
                                <col width="170">
                                <col width="170">
                            </colgroup>
                            <thead>
                                <tr>
                                    <th>No.</th>
                                    <th>원료명</th>
                                    <th>원료시험번호</th>
                                    <th>함량(%)</th>
                                    <th>제조지시량(kg)</th>
                                    <th>제조지시량(g)</th>
                                    <th>단가</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                        <span class="row-num">1</span>
                                    </td>
                                    <td><input type="text" name="raw_material_name" class="inputText item-autocomplete" placeholder="원료명 입력"></td>
                                    <td><input type="text" name="test_number" class="inputText"></td>
                                    <td><div class="unit"><input type="text" name="content_pct" class="inputText row-content-pct" inputmode="decimal"><i>%</i></div></td>
                                    <td><div class="unit"><input type="text" name="order_qty_kg" class="inputText order-kg" inputmode="decimal"><i>kg</i></div></td>
                                    <td><div class="unit"><input type="text" name="order_qty_g" class="inputText order-g" inputmode="decimal"><i>g</i></div></td>
                                    <td><div class="unit"><input type="text" name="unit_price" class="inputText item-price" inputmode="decimal"><i>원</i></div></td>
                                </tr>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td colspan="3">합계</td>
                                    <td><div class="unit"><input type="text" name="total_content_pct" class="inputText total-pct" inputmode="decimal" readonly><i>%</i></div></td>
                                    <td><div class="unit"><input type="text" name="total_kg" class="inputText total-kg" inputmode="decimal" readonly><i>kg</i></div></td>
                                    <td><div class="unit"><input type="text" name="total_g" class="inputText total-g" inputmode="decimal" readonly><i>g</i></div></td>
                                    <td><div class="unit"><input type="text" name="total_price" class="inputText total-price" inputmode="decimal" readonly><i>원</i></div></td>
                                </tr>
                            </tfoot>
                        </table>
                        <div class="add_btn">
                            <button type="button" id="addRowBtn" class="Button">원료 행 추가</button>
                        </div>
                    </section>
                    <section class="radius">
                        <table class="phase_table">
                            <colgroup>
                                <col width="100">
                                <col width="230">
                            </colgroup>
                            <thead>
                                <tr>
                                    <th>상</th>
                                    <th>선택</th>
                                    <th>제조방법</th>
                                    <th>비고</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <th>
                                        <span class="phase-name">A상</span><input type="hidden" name="phase_title" value="A상" class="phase-title-input">
                                    </th>
                                    <td>
                                        <div class="phase_num">
                                            <select name="phase_start" class="og_select phase-start-sel"></select>
                                            <i>~</i>
                                            <select name="phase_end" class="og_select phase-end-sel"></select>
                                        </div>
                                    </td>
                                    <td>
                                        <textarea name="method_desc" class="textArea" placeholder="제조방법 입력"></textarea>
                                    </td>
                                    <td>
                                        <textarea name="note_desc" class="textArea" placeholder="비고 입력"></textarea>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <div class="add_btn">
                            <button type="button" id="addPhaseBtn" class="Button">추가</button>
                        </div>
                    </section>
                    <div class="bottom_btns">
                        <button type="button" class="Button bgGray" data-width="100" onclick="history.back();">취소</button>
                        <button type="submit" class="Button bgBlue" data-width="100">신규등록</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        // 숫자 천단위 콤마 포맷 함수
        function formatWithComma(value) {
            if (!value) return "";
            let parts = value.toString().split('.');
            parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
            return parts.join('.');
        }

        // 상단 제조지시량을 기준으로 한 총 그람(g) 제한값 계산 함수
        function getTopTargetGrams() {
            let val = parseFloat($(".top-target-qty").val().replace(/,/g, '')) || 0;
            let unit = $(".top-target-unit").val();
            if (unit === 'kg') {
                return val * 1000;
            } else {
                return val;
            }
        }

        // 개별 행의 단가 자동 계산 함수 (원료 기준 단가 * 총 제조지시량(kg) * (함량% / 100))
        function calculateRowPrice($row) {
            let unitPricePerKg = parseFloat($row.find('.item-price').data('unit-price-per-kg')) || 0;
            let topTargetKg = getTopTargetGrams() / 1000;
            let pct = parseFloat($row.find('.row-content-pct').val().replace(/,/g, '')) || 0;

            if (unitPricePerKg > 0 && pct > 0 && topTargetKg > 0) {
                let calculatedPrice = unitPricePerKg * topTargetKg * (pct / 100);
                $row.find('.item-price').val(formatWithComma(Math.round(calculatedPrice)));
            } else if (pct === 0) {
                $row.find('.item-price').val('');
            }
        }

        // 합계 및 유효성 검사 갱신 함수
        function updateTotalsAndValidate() {
            let totalPct = 0;
            let totalKg = 0;
            let totalG = 0;
            let totalPrice = 0;

            $(".order_table tbody tr").each(function () {
                let pct = parseFloat($(this).find(".row-content-pct").val().replace(/,/g, '')) || 0;
                let kg = parseFloat($(this).find(".order-kg").val().replace(/,/g, '')) || 0;
                let g = parseFloat($(this).find(".order-g").val().replace(/,/g, '')) || 0;
                let price = parseFloat($(this).find(".item-price").val().replace(/,/g, '')) || 0;

                totalPct += pct;
                totalKg += kg;
                totalG += g;
                totalPrice += price;
            });

            $(".order_table tfoot .total-pct").val(formatWithComma(Number(totalPct.toFixed(4))));
            $(".order_table tfoot .total-kg").val(formatWithComma(Number(totalKg.toFixed(4))));
            $(".order_table tfoot .total-g").val(formatWithComma(Number(totalG.toFixed(4))));
            $(".order_table tfoot .total-price").val(formatWithComma(Math.round(totalPrice)));
        }

        $(document).ready(function () {
            // 원료명 자동완성 공통 함수
            function initAutocomplete($elem) {
                $elem.autocomplete({
                    source: "getItemAutoComplete.jsp",
                    minLength: 1,
                    select: function (event, ui) {
                        let $row = $(this).closest('tr');
                        // 1kg당 단가를 data 속성에 임시 저장해둠
                        $row.find('.item-price').data('unit-price-per-kg', ui.item.price);
                        
                        // 원료가 선택될 때 함량(%)이 이미 입력되어 있다면 제조지시량 및 단가 즉시 자동 계산
                        let pct = parseFloat($row.find('.row-content-pct').val().replace(/,/g, '')) || 0;
                        let topGrams = getTopTargetGrams();
                        if (pct > 0 && topGrams > 0) {
                            let assignedGrams = topGrams * (pct / 100);
                            let assignedKg = assignedGrams / 1000;
                            
                            $row.find('.order-kg').val(formatWithComma(Number(assignedKg.toFixed(4))));
                            $row.find('.order-g').val(formatWithComma(Number(assignedGrams.toFixed(4))));
                        }

                        calculateRowPrice($row);
                        updateTotalsAndValidate();
                    }
                });
            }

            // 상(Phase) 이름 및 삭제 버튼 상태 갱신 함수
            function updatePhaseNamesAndDeletes() {
                let totalPhases = $(".phase_table tbody tr").length;
                $(".phase_table tbody tr").each(function (index) {
                    let phaseChar = String.fromCharCode(65 + index);
                    let phaseName = phaseChar + "상";
                    
                    $(this).find(".phase-name").text(phaseName);
                    $(this).find(".phase-title-input").val(phaseName);

                    let $th = $(this).find("th");
                    $th.find(".delPhaseBtn").remove();

                    if (index > 0) {
                        let delBtnHtml = '<button type="button" class="delPhaseBtn" title="삭제">삭제</button>';
                        $th.append(delBtnHtml);
                    }
                });
            }

            // 원료 행 개수에 맞춰 모든 상(Phase)의 선택 셀렉트박스 옵션 및 범위 갱신
            function updateAllPhaseSelects() {
                let totalRows = $(".order_table tbody tr").length;
                let previousEnd = 0;

                $(".phase_table tbody tr").each(function (index) {
                    let $startSel = $(this).find(".phase-start-sel");
                    let $endSel = $(this).find(".phase-end-sel");

                    let currentStartVal = parseInt($startSel.val()) || (previousEnd + 1);
                    let currentEndVal = parseInt($endSel.val()) || totalRows;

                    if (currentStartVal > totalRows) currentStartVal = totalRows;
                    if (currentEndVal > totalRows) currentEndVal = totalRows;
                    if (currentEndVal < currentStartVal) currentEndVal = currentStartVal;

                    if (index > 0) {
                        currentStartVal = previousEnd + 1;
                        if (currentStartVal > totalRows) currentStartVal = totalRows;
                        if (currentEndVal < currentStartVal) currentEndVal = currentStartVal;
                    }

                    let optionsHtml = "";
                    for (let i = 1; i <= totalRows; i++) {
                        optionsHtml += `<option value="` + i + `">` + i + `</option>`;
                    }

                    $startSel.html(optionsHtml);
                    $endSel.html(optionsHtml);

                    $startSel.val(currentStartVal);
                    $endSel.val(currentEndVal);

                    previousEnd = currentEndVal;
                });
            }

            // 행 번호(No.) 및 상 셀렉트박스 갱신 통합 함수
            function updateRowIndices() {
                $(".order_table tbody tr").each(function (index) {
                    $(this).find(".row-num").text(index + 1);
                });
                updateAllPhaseSelects();
            }

            // 페이지 로드 시 초기 실행
            initAutocomplete($(".item-autocomplete"));
            updatePhaseNamesAndDeletes();
            updateAllPhaseSelects();
            updateTotalsAndValidate();

            // 원료 행 동적 추가 버튼 이벤트
            $("#addRowBtn").on("click", function () {
                let newRow = `
                    <tr>
                        <td>
                            <span class="row-num"></span>
                            <button type="button" class="delRowBtn" title="삭제">삭제</button>
                        </td>
                        <td><input type="text" name="raw_material_name" class="inputText item-autocomplete" placeholder="원료명 입력"></td>
                        <td><input type="text" name="test_number" class="inputText"></td>
                        <td><div class="unit"><input type="text" name="content_pct" class="inputText row-content-pct" inputmode="decimal"><i>%</i></div></td>
                        <td><div class="unit"><input type="text" name="order_qty_kg" class="inputText order-kg" inputmode="decimal"><i>kg</i></div></td>
                        <td><div class="unit"><input type="text" name="order_qty_g" class="inputText order-g" inputmode="decimal"><i>g</i></div></td>
                        <td><div class="unit"><input type="text" name="unit_price" class="inputText item-price" inputmode="decimal"><i>원</i></div></td>
                    </tr>
                `;
                $(".order_table tbody").append(newRow);
                
                updateRowIndices();
                initAutocomplete($(".order_table tbody tr:last-child .item-autocomplete"));
                updateTotalsAndValidate();
            });

            // 원료 행 삭제 이벤트
            $(document).on("click", ".delRowBtn", function () {
                $(this).closest("tr").remove();
                updateRowIndices();
                updateTotalsAndValidate();
            });

            // 상(Phase) 행 추가 버튼 이벤트
            $("#addPhaseBtn").on("click", function () {
                let totalRows = $(".order_table tbody tr").length;
                
                let lastEnd = 1;
                let $lastEndSel = $(".phase_table tbody tr:last-child .phase-end-sel");
                if ($lastEndSel.length > 0) {
                    lastEnd = parseInt($lastEndSel.val()) || totalRows;
                }
                
                let nextStart = lastEnd + 1;
                if (nextStart > totalRows) nextStart = totalRows;
                let nextEnd = totalRows;

                let optionsHtml = "";
                for (let i = 1; i <= totalRows; i++) {
                    optionsHtml += `<option value="` + i + `">` + i + `</option>`;
                }

                let newPhaseRow = `
                    <tr>
                        <th>
                            <span class="phase-name"></span><input type="hidden" name="phase_title" value="" class="phase-title-input">
                        </th>
                        <td>
                            <div class="phase_num">
                                <select name="phase_start" class="og_select phase-start-sel">` + optionsHtml + `</select>
                                <i>~</i>
                                <select name="phase_end" class="og_select phase-end-sel">` + optionsHtml + `</select>
                            </div>
                        </td>
                        <td>
                            <textarea name="method_desc" class="textArea" placeholder="제조방법 입력"></textarea>
                        </td>
                        <td>
                            <textarea name="note_desc" class="textArea" placeholder="비고 입력"></textarea>
                        </td>
                    </tr>
                `;

                $(".phase_table tbody").append(newPhaseRow);
                updatePhaseNamesAndDeletes();

                let $newRow = $(".phase_table tbody tr:last-child");
                $newRow.find(".phase-start-sel").val(nextStart);
                $newRow.find(".phase-end-sel").val(nextEnd);
            });

            // 상(Phase) 행 삭제 이벤트
            $(document).on("click", ".delPhaseBtn", function () {
                $(this).closest("tr").remove();
                updatePhaseNamesAndDeletes();
                updateAllPhaseSelects();
            });

            // 상의 종료(end) 셀렉트박스 변경 시 연동
            $(document).on("change", ".phase-end-sel", function () {
                updateAllPhaseSelects();
            });

            // 상단 제조지시량 및 이론제조량 콤마 및 입력 제어
            $(document).on('input', 'input[name="target_qty"], input[name="theor_qty"]', function() {
                let $this = $(this);
                let value = $this.val().replace(/[^0-9.]/g, '');
                let parts = value.split('.');
                if (parts.length > 2) value = parts[0] + '.' + parts.slice(1).join('');

                $this.val(formatWithComma(value));
            });

            // 상단 제조지시량 변경 시 기존 입력된 행들의 제조지시량 및 단가 자동 재계산 연동
            $(document).on('input change', '.top-target-qty, .top-target-unit', function() {
                let topGrams = getTopTargetGrams();
                $(".order_table tbody tr").each(function () {
                    let $row = $(this);
                    let pct = parseFloat($row.find('.row-content-pct').val().replace(/,/g, '')) || 0;
                    if (pct > 0 && topGrams > 0) {
                        let assignedGrams = topGrams * (pct / 100);
                        let assignedKg = assignedGrams / 1000;
                        
                        $row.find('.order-kg').val(formatWithComma(Number(assignedKg.toFixed(4))));
                        $row.find('.order-g').val(formatWithComma(Number(assignedGrams.toFixed(4))));
                        calculateRowPrice($row);
                    }
                });
                updateTotalsAndValidate();
            });

            // 함량(%) 입력 시 제조지시량(kg, g) 및 단가 자동 계산 로직
            $(document).on('input', '.row-content-pct', function() {
                let $this = $(this);
                let value = $this.val().replace(/[^0-9.]/g, '');
                let parts = value.split('.');
                if (parts.length > 2) value = parts[0] + '.' + parts.slice(1).join('');
                
                let enteredVal = parseFloat(value) || 0;

                let $row = $this.closest('tr');
                let otherTotalPct = 0;
                $(".order_table tbody tr").not($row).each(function() {
                    otherTotalPct += parseFloat($(this).find('.row-content-pct').val().replace(/,/g, '')) || 0;
                });

                let maxAllowedPct = 100 - otherTotalPct;
                if (maxAllowedPct < 0) maxAllowedPct = 0;

                if (enteredVal > maxAllowedPct) {
                    alert("함량(%)의 총합은 100%를 초과할 수 없습니다. (최대 입력 가능: " + maxAllowedPct + "%)");
                    enteredVal = maxAllowedPct;
                    value = enteredVal.toString();
                }

                $this.val(formatWithComma(value));

                let topGrams = getTopTargetGrams();
                if (topGrams > 0 && enteredVal > 0) {
                    let assignedGrams = topGrams * (enteredVal / 100);
                    let assignedKg = assignedGrams / 1000;

                    $row.find('.order-kg').val(formatWithComma(Number(assignedKg.toFixed(4))));
                    $row.find('.order-g').val(formatWithComma(Number(assignedGrams.toFixed(4))));
                } else if (enteredVal === 0) {
                    $row.find('.order-kg').val('');
                    $row.find('.order-g').val('');
                }

                calculateRowPrice($row);
                updateTotalsAndValidate();
            });

            // 제조지시량(kg ⇄ g) 직접 수정 시 함량(%) 역산, 단가 재계산 및 상단 제조지시량 초과 제한 로직
            $(document).on('input', '.order_table input[inputmode="decimal"]', function() {
                let $this = $(this);
                if ($this.is(':disabled') || $this.prop('readonly') || $this.hasClass('row-content-pct')) return;

                let value = $this.val().replace(/[^0-9.]/g, '');
                const parts = value.split('.');
                if (parts.length > 2) value = parts[0] + '.' + parts.slice(1).join('');

                let $row = $this.closest('tr');
                if (!value || value === '.') {
                    $this.val('');
                    if ($this.hasClass('order-kg')) $row.find('.order-g').val('');
                    else if ($this.hasClass('order-g')) $row.find('.order-kg').val('');
                    $row.find('.row-content-pct').val(''); // 지시량 지우면 함량도 초기화
                    calculateRowPrice($row);
                    updateTotalsAndValidate();
                    return;
                }

                let numValue = parseFloat(value.replace(/,/g, ''));
                if (isNaN(numValue)) return;

                let topLimitGrams = getTopTargetGrams();

                if (topLimitGrams > 0) {
                    let otherGrams = 0;
                    $(".order_table tbody tr").not($row).each(function() {
                        otherGrams += parseFloat($(this).find('.order-g').val().replace(/,/g, '')) || 0;
                    });

                    let maxAllowedGrams = topLimitGrams - otherGrams;
                    if (maxAllowedGrams < 0) maxAllowedGrams = 0;

                    let currentGrams = $this.hasClass('order-kg') ? (numValue * 1000) : numValue;

                    if (currentGrams > maxAllowedGrams) {
                        alert("합계 제조지시량은 상단의 제조지시량(" + $(".top-target-qty").val() + " " + $(".top-target-unit").val() + ")을 초과할 수 없습니다.");
                        if ($this.hasClass('order-kg')) {
                            numValue = maxAllowedGrams / 1000;
                        } else {
                            numValue = maxAllowedGrams;
                        }
                        value = Number(numValue.toFixed(4)).toString();
                    }
                }

                // 입력된 지시량을 기준으로 상단 총량 대비 함량(%) 역산 계산
                let currentGramsForCalc = $this.hasClass('order-kg') ? (numValue * 1000) : numValue;
                if (topLimitGrams > 0) {
                    let calculatedPct = (currentGramsForCalc / topLimitGrams) * 100;
                    $row.find('.row-content-pct').val(formatWithComma(Number(calculatedPct.toFixed(4))));
                }

                $this.val(formatWithComma(value));

                if ($this.hasClass('order-kg')) {
                    let calculatedG = numValue * 1000;
                    let calcStr = Number(calculatedG.toFixed(4)).toString();
                    $row.find('.order-g').val(formatWithComma(calcStr));
                }
                else if ($this.hasClass('order-g')) {
                    let calculatedKg = numValue / 1000;
                    let calcStr = Number(calculatedKg.toFixed(4)).toString();
                    $row.find('.order-kg').val(formatWithComma(calcStr));
                }

                calculateRowPrice($row);
                updateTotalsAndValidate();
            });

            // 폼 제출 전 decimal 입력값들의 콤마 제거 정리
            $('#regForm').on('submit', function () {
                $(this).find('input[inputmode="decimal"]').not(':disabled').each(function () {
                    let rawVal = $(this).val().replace(/,/g, '');
                    if(rawVal === '') rawVal = '0';
                    $(this).val(rawVal);
                });
            });
        });
    </script>
<jsp:include page="/app/include/FooterDocType.jsp" />