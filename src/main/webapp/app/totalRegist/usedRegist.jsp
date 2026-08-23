<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content registPage totalReg">
                <div class="title_set">
                    <h5 class="page_tit"><p>사용등록</p></h5>
                </div>
                <div class="top_control">
                    <button type="button" class="raw on" data-target="raw">원료</button>
                    <button type="button" class="subsidiary" data-target="subsidiary">부자재</button>
                </div>
                
                <!--원료-->
                <form class="raw" action="usedRegistAction.jsp" method="post" style="display: block;">
                    <input type="hidden" name="category" value="RAW">
                    <section class="radius">
                        <dl class="w75">
                            <dt>원료명</dt>
                            <dd><input type="text" id="raw_item_name" name="item_name" class="inputText" placeholder="원료명 입력 (자동완성)"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>Lot번호</dt>
                            <dd><input type="text" name="lot_number" class="inputText" placeholder="Lot 입력"></dd>
                        </dl>
                        <dl class="volume stock">
                            <dt>사용량</dt>
                            <dd>
                                <div class="unit_t"><input type="text" name="out_qty_t" class="inputText" inputmode="decimal"><i>t</i></div>
                                <div class="unit_kg"><input type="text" name="out_qty_kg" class="inputText" inputmode="decimal"><i>kg</i></div>
                                <div class="unit_g"><input type="text" name="out_qty_g" class="inputText" inputmode="decimal"><i>g</i></div>
                                <div class="unit_mg"><input type="text" name="out_qty_mg" class="inputText" inputmode="decimal"><i>mg</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="180" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="180">사용등록</button>
                        </div>
                        <!--Lot 리스트 팝업-->
                        <div class="layer_popup" id="itemLotPopup" style="display: none;">
                            <div class="pop_data people_pop" data-width="860">
                                <div class="head">
                                    <h6>원료 리스트</h6>
                                    <button type="button" class="close btn_close_pop" title="닫기"><img src="/images/svg/popup_close.svg"></button>
                                </div>
                                <div class="body">
                                    <ul id="lot_list_ul">

                                    </ul>
                                </div>
                                <div class="bottom_btns">
                                    <button type="button" id="btn_item_apply_lots" class="Button bgBlue" data-width="180">적용</button>
                                </div>
                            </div>
                        </div>
                        <!--//Lot 리스트 팝업-->
                    </section>
                </form>

                <!--부자재-->
                <form class="subsidiary" action="usedRegistAction.jsp" method="post">
                    <input type="hidden" name="category" value="SUBSIDIARY">
                    <section class="radius">
                        <dl class="w75">
                            <dt>자재명</dt>
                            <dd><input type="text" id="sub_item_name" name="item_name" class="inputText" placeholder="자재명 입력 (자동완성)"></dd>
                        </dl>
                        <dl class="volume stock w25">
                            <dt>사용개수</dt>
                            <dd>
                                <div class="unit_ea"><input type="text" name="out_qty" class="inputText" inputmode="decimal"><i>개</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="180" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="180">사용등록</button>
                        </div>
                    </section>
                </form>
            </div>
        </div>
        
        <script>
            $(document).ready(function() {
                // 원료 '사용등록' 전용 Map 선언
                let rawUseLotMap = new Map();

                // 품목명 Autocomplete (searchItems.jsp 호출)
                function setupAutocomplete(elementId, categoryName) {
                    $(elementId).autocomplete({
                        source: function(request, response) {
                            $.ajax({
                                url: "searchItems.jsp",
                                type: "GET",
                                data: {
                                    category: categoryName,
                                    keyword: request.term
                                },
                                dataType: "json",
                                success: function(data) {
                                    response(data);
                                }
                            });
                        },
                        minLength: 1,
                        appendTo: "body"
                    });
                }

                setupAutocomplete("#raw_item_name", "RAW");
                setupAutocomplete("#sub_item_name", "SUBSIDIARY");

                // Lot 번호 Autocomplete (searchLots.jsp 호출)
                function setupLotAutocomplete(lotInputSelector, nameInputSelector, categoryName) {
                    $(lotInputSelector).autocomplete({
                        source: function (request, response) {
                            $.ajax({
                                url: "searchLots.jsp",
                                type: "GET",
                                data: {
                                    category: categoryName,
                                    item_name: $(nameInputSelector).val(),
                                    keyword: request.term
                                },
                                dataType: "json",
                                success: function (data) {
                                    response(data);
                                }
                            });
                        },
                        minLength: 1,
                        appendTo: "body"
                    });
                }

                // 원료 Lot번호 자동완성 연결
                setupLotAutocomplete("form.raw input[name='lot_number']", "#raw_item_name", "RAW");

                // 숫자 포맷 함수
                function formatNumberAuto(num) {
                    if (num >= 1000000) {
                        return new Intl.NumberFormat('en-US', { notation: 'compact', maximumFractionDigits: 1 }).format(num);
                    } else {
                        return new Intl.NumberFormat('en-US').format(num);
                    }
                }

                // ★ Lot번호 input 클릭/포커스 시 레이어 팝업 표시
                $("form.raw input[name='lot_number']").on("click focus", function () {
                    let rawName = $("#raw_item_name").val().trim();

                    if (rawName !== "") {
                        $.ajax({
                            url: "getItemLots.jsp",
                            type: "GET",
                            data: {
                                item_name: rawName
                            },
                            dataType: "json",
                            success: function (lotList) {
                                let $ul = $("#lot_list_ul");
                                $ul.empty(); // 기존 목록 초기화

                                if (!lotList || lotList.length === 0) {
                                    $ul.html('<li style="text-align:center; padding: 15px;">등록된 Lot이 없습니다.</li>');
                                } else {
                                    $.each(lotList, function (idx, item) {
                                        let rawT = item.stock_qty_t || 0;
                                        let rawKg = item.stock_qty_kg || 0;
                                        let rawG = item.stock_qty_g || 0;
                                        let rawMg = item.stock_qty_mg || 0;

                                        let t = formatNumberAuto(rawT);
                                        let kg = formatNumberAuto(rawKg);
                                        let g = formatNumberAuto(rawG);
                                        let mg = formatNumberAuto(rawMg);

                                        // ★ 이전에 rawUseLotMap에 저장해 둔 값이 있다면 가져옴
                                        let saved = rawUseLotMap.get(item.lot_number) || { t: '', kg: '', g: '', mg: '' };

                                        let html = '<li>'
                                            + '    <dl class="lot">'
                                            + '        <dt>Lot번호</dt>'
                                            + '        <dd>' + item.lot_number + '</dd>'
                                            + '    </dl>'
                                            + '    <dl class="stock">'
                                            + '        <dt>현재재고</dt>'
                                            + '        <dd>'
                                            + '            <i>' + t + '</i> t / '
                                            + '            <i>' + kg + '</i> kg / '
                                            + '            <i>' + g + '</i> g / '
                                            + '            <i>' + mg + '</i> mg'
                                            + '        </dd>'
                                            + '    </dl>'
                                            + '    <dl class="volume">'
                                            + '        <dt>사용량 <button type="button" class="btn_all_use"'
                                            + '            data-t="' + rawT + '"'
                                            + '            data-kg="' + rawKg + '"'
                                            + '            data-g="' + rawG + '"'
                                            + '            data-mg="' + rawMg + '">전체사용</button></dt>'
                                            + '        <dd>'
                                            + '            <div class="unit_t"><input type="text" class="inputText lot_qty_input" data-lot="' + item.lot_number + '" data-unit="t" value="' + saved.t + '" inputmode="decimal"><i>t</i></div>'
                                            + '            <div class="unit_kg"><input type="text" class="inputText lot_qty_input" data-lot="' + item.lot_number + '" data-unit="kg" value="' + saved.kg + '" inputmode="decimal"><i>kg</i></div>'
                                            + '            <div class="unit_g"><input type="text" class="inputText lot_qty_input" data-lot="' + item.lot_number + '" data-unit="g" value="' + saved.g + '" inputmode="decimal"><i>g</i></div>'
                                            + '            <div class="unit_mg"><input type="text" class="inputText lot_qty_input" data-lot="' + item.lot_number + '" data-unit="mg" value="' + saved.mg + '" inputmode="decimal"><i>mg</i></div>'
                                            + '        </dd>'
                                            + '    </dl>'
                                            + '</li>';
                                        $ul.append(html);
                                    });
                                }
                                $("#itemLotPopup").show();
                            },
                            error: function (xhr, status, error) {
                                console.error("Error:", error);
                                alert("Lot 목록을 불러오는 중 오류가 발생했습니다.");
                            }
                        });
                    }
                });

                // 동적으로 생성된 전체사용 버튼에 클릭 이벤트 위임
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
                });

                // 팝업창의 [적용] 버튼을 눌렀을 때
                $(document).on("click", "#btn_item_apply_lots", function () {
                    let totalT = 0;
                    let totalKg = 0;
                    let totalG = 0;
                    let totalMg = 0;

                    rawUseLotMap.clear();

                    // 기존에 생성된 동적 hidden 태그 제거
                    $("form.raw input.dynamic_lot_input").remove();
                    let $form = $("form.raw");
                    let idx = 0;

                    $("#itemLotPopup #lot_list_ul li").each(function () {
                        let $li = $(this);
                        let lotNumber = $li.find(".lot dd").text().trim();

                        let valT = $li.find(".unit_t input").val();
                        let valKg = $li.find(".unit_kg input").val();
                        let valG = $li.find(".unit_g input").val();
                        let valMg = $li.find(".unit_mg input").val();

                        if (valT || valKg || valG || valMg) {
                            rawUseLotMap.set(lotNumber, { t: valT, kg: valKg, g: valG, mg: valMg });

                            // ★ 서버로 각 Lot별 사용량을 정확히 전달하기 위한 hidden 필드 생성
                            $form.append('<input type="hidden" name="lotUsages[' + idx + '].lot_number" class="dynamic_lot_input" value="' + lotNumber + '">');
                            $form.append('<input type="hidden" name="lotUsages[' + idx + '].t" class="dynamic_lot_input" value="' + (valT ? valT.replace(/,/g, '') : 0) + '">');
                            $form.append('<input type="hidden" name="lotUsages[' + idx + '].kg" class="dynamic_lot_input" value="' + (valKg ? valKg.replace(/,/g, '') : 0) + '">');
                            $form.append('<input type="hidden" name="lotUsages[' + idx + '].g" class="dynamic_lot_input" value="' + (valG ? valG.replace(/,/g, '') : 0) + '">');
                            $form.append('<input type="hidden" name="lotUsages[' + idx + '].mg" class="dynamic_lot_input" value="' + (valMg ? valMg.replace(/,/g, '') : 0) + '">');
                            idx++;
                        }

                        let t = parseFloat((valT || "0").replace(/,/g, '')) || 0;
                        let kg = parseFloat((valKg || "0").replace(/,/g, '')) || 0;
                        let g = parseFloat((valG || "0").replace(/,/g, '')) || 0;
                        let mg = parseFloat((valMg || "0").replace(/,/g, '')) || 0;

                        totalT += t;
                        totalKg += kg;
                        totalG += g;
                        totalMg += mg;
                    });

                    // 메인 화면의 각 단위별 입력란에 합산된 결과 대입
                    $("form.raw input[name='out_qty_t']").val(totalT > 0 ? totalT.toLocaleString('en-US') : "");
                    $("form.raw input[name='out_qty_kg']").val(totalKg > 0 ? totalKg.toLocaleString('en-US') : "");
                    $("form.raw input[name='out_qty_g']").val(totalG > 0 ? totalG.toLocaleString('en-US') : "");
                    $("form.raw input[name='out_qty_mg']").val(totalMg > 0 ? totalMg.toLocaleString('en-US') : "");

                    $("#itemLotPopup").hide();
                });

                // 수량 단위 자동 환산 관련 로직
                const unitToGram = {
                    'unit_t': 1000000,
                    'unit_kg': 1000,
                    'unit_g': 1,
                    'unit_mg': 0.001
                };

                function formatWithComma(str) {
                    if (!str) return '';
                    const parts = str.split('.');
                    parts[0] = parts[0].replace(/,/g, '').replace(/\B(?=(\d{3})+(?!\d))/g, ',');
                    return parts.join('.');
                }

                let $userInput = null;

                $(document).on('input', 'input[inputmode="decimal"]', function() {
                    let $this = $(this);
                    $userInput = $this;
                    let value = $this.val();

                    value = value.replace(/[^0-9.]/g, '');

                    const parts = value.split('.');
                    if (parts.length > 2) {
                        value = parts[0] + '.' + parts.slice(1).join('');
                    }

                    let formattedValue = formatWithComma(value);
                    $this.val(formattedValue);

                    const $parentGroup = $this.closest('dl');
                    const $parentDiv = $this.parent('div');
                    const currentUnitClass = $parentDiv.attr('class').split(' ').find(cls => cls.startsWith('unit_'));

                    if (!value || value === '.') {
                        $parentGroup.find('input[inputmode="decimal"]').not($this).val('');
                        return;
                    }

                    const rawNumberString = value.replace(/,/g, '');
                    const numValue = parseFloat(rawNumberString);
                    if (isNaN(numValue)) return;

                    const baseGrams = numValue * unitToGram[currentUnitClass];

                    $.each(unitToGram, function(unitClass, ratio) {
                        if (unitClass !== currentUnitClass) {
                            let calculated = baseGrams / ratio;
                            let calcStr = Number(calculated.toFixed(6)).toString(); 
                            let finalFormatted = formatWithComma(calcStr);
                            $parentGroup.find('.' + unitClass + ' input').val(finalFormatted);
                        }
                    });
                });

                // Form Submit 시 처리
                $('form').on('submit', function () {
                    const $parentGroup = $(this).find('dl.volume');
                    
                    if ($userInput && $userInput.length > 0) {
                        $parentGroup.find('input[inputmode="decimal"]').not($userInput).val('');
                    }

                    $(this).find('input[inputmode="decimal"]').each(function () {
                        let rawVal = $(this).val().replace(/,/g, '');
                        $(this).val(rawVal);
                    });
                });
            });
        </script>
    </div>
<jsp:include page="/app/include/FooterDocType.jsp" />