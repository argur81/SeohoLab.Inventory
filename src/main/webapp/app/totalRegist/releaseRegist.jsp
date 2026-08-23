<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content registPage totalReg">
                <div class="title_set">
                    <h5 class="page_tit"><p>출고등록</p></h5>
                </div>
                <div class="top_control">
                    <button type="button" class="raw on" data-target="raw">원료</button>
                    <button type="button" class="product" data-target="product">제품</button>
                </div>
                
                <!--원료-->
                <form class="raw" action="releaseRegistAction.jsp" method="post" style="display: block;">
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
                            <dt>출고량</dt>
                            <dd>
                                <div class="unit_t"><input type="text" name="out_qty_t" class="inputText" inputmode="decimal"><i>t</i></div>
                                <div class="unit_kg"><input type="text" name="out_qty_kg" class="inputText" inputmode="decimal"><i>kg</i></div>
                                <div class="unit_g"><input type="text" name="out_qty_g" class="inputText" inputmode="decimal"><i>g</i></div>
                                <div class="unit_mg"><input type="text" name="out_qty_mg" class="inputText" inputmode="decimal"><i>mg</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="180" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="180">출고등록</button>
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

                <!--제품-->
                <form class="product" action="releaseRegistAction.jsp" method="post">
                    <input type="hidden" name="category" value="PRODUCT">
                    <section class="radius">
                        <dl class="w25">
                            <dt>제품명</dt>
                            <dd><input type="text" id="product_item_name" name="item_name" class="inputText" placeholder="제품명 입력 (자동완성)"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>종류</dt>
                            <dd>
                                <select class="og_select" name="product_type">
                                    <option value="">선택</option>
                                    <option value="에센스·세럼·앰플">에센스·세럼·앰플</option>
                                    <option value="샴푸">샴푸</option>
                                    <option value="미스트">미스트</option>
                                    <option value="크림">크림</option>
                                    <option value="토너·스킨">토너·스킨</option>
                                    <option value="패드(토너패드·패드팩)">패드(토너패드·패드팩)</option>
                                    <option value="로션·에멀전">로션·에멀전</option>
                                    <option value="아이크림">아이크림</option>
                                    <option value="페이스 오일">페이스 오일</option>
                                    <option value="클렌징 폼">클렌징 폼</option>
                                    <option value="클렌징 오일·워터·림">클렌징 오일·워터·림</option>
                                    <option value="클렌징 티슈">클렌징 티슈</option>
                                    <option value="필링젤·스크럽">필링젤·스크럽</option>
                                    <option value="선크림">선크림</option>
                                    <option value="기타">기타</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>Lot번호</dt>
                            <dd><input type="text" name="lot_number" class="inputText" placeholder="Lot 입력"></dd>
                        </dl>
                        <dl class="volume stock w25">
                            <dt>출고개수</dt>
                            <dd>
                                <div class="unit_ea"><input type="text" name="out_qty" class="inputText" inputmode="decimal"><i>개</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="180" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="180">출고등록</button>
                        </div>
                        <!-- 제품 Lot 리스트 팝업 추가 -->
                        <div class="layer_popup" id="productLotPopup" style="display: none;">
                            <div class="pop_data people_pop" data-width="860">
                                <div class="head">
                                    <h6>제품 Lot 리스트</h6>
                                    <button type="button" class="close btn_close_pop" title="닫기"><img src="/images/svg/popup_close.svg"></button>
                                </div>
                                <div class="body">
                                    <ul id="product_lot_list_ul"></ul>
                                </div>
                                <div class="bottom_btns">
                                    <button type="button" id="btn_product_apply_lots" class="Button bgBlue" data-width="180">적용</button>
                                </div>
                            </div>
                        </div>
                        <!-- //제품 Lot 리스트 팝업 추가 -->
                    </section>
                </form>
                <!--//제품-->
            </div>
        </div>
        
        <script>
            $(document).ready(function() {
                // 원료/제품 '출고등록' 전용 Map 선언
                let rawUseLotMap = new Map();
                let productUseLotMap = new Map();

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
                        appendTo: "body",
                        select: function (event, ui) {
                            if (categoryName === "PRODUCT") {
                                if (ui.item.type) {
                                    $("form.product select[name='product_type']").val(ui.item.type).trigger('change');
                                }
                            }
                        }
                    });
                }
                
                setupAutocomplete("#product_item_name", "PRODUCT");
                setupAutocomplete("#raw_item_name", "RAW");

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

                // 원료/제품 Lot번호 자동완성 연결
                setupLotAutocomplete("form.raw input[name='lot_number']", "#raw_item_name", "RAW");
                setupLotAutocomplete("form.product input[name='lot_number']", "#product_item_name", "PRODUCT");

                // 숫자 포맷 함수
                function formatNumberAuto(num) {
                    if (num >= 1000000) {
                        return new Intl.NumberFormat('en-US', { notation: 'compact', maximumFractionDigits: 1 }).format(num);
                    } else {
                        return new Intl.NumberFormat('en-US').format(num);
                    }
                }

                //■■■■■■원료■■■■■■

                // 원료 Lot번호 input 클릭/포커스 시 레이어 팝업 표시
                $("form.raw input[name='lot_number']").on("click focus", function () {
                    let rawName = $("#raw_item_name").val().trim();

                    if (rawName !== "") {
                        $.ajax({
                            url: "getItemLots.jsp",
                            type: "GET",
                            data: {
                                item_name: rawName,
                                category: "RAW"
                            },
                            dataType: "json",
                            success: function (lotList) {
                                let $ul = $("#lot_list_ul");
                                $ul.empty();

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
                                            + '        <dt>출고량 <button type="button" class="btn_all_use"'
                                            + '            data-t="' + rawT + '"'
                                            + '            data-kg="' + rawKg + '"'
                                            + '            data-g="' + rawG + '"'
                                            + '            data-mg="' + rawMg + '">전체출고</button></dt>'
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

                // 원료 전체출고 버튼
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

                // 원료 팝업 [적용] 버튼
                $(document).on("click", "#btn_item_apply_lots", function () {
                    let totalT = 0, totalKg = 0, totalG = 0, totalMg = 0;
                    rawUseLotMap.clear();
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
                            $form.append('<input type="hidden" name="lotUsages[' + idx + '].lot_number" class="dynamic_lot_input" value="' + lotNumber + '">');
                            $form.append('<input type="hidden" name="lotUsages[' + idx + '].t" class="dynamic_lot_input" value="' + (valT ? valT.replace(/,/g, '') : 0) + '">');
                            $form.append('<input type="hidden" name="lotUsages[' + idx + '].kg" class="dynamic_lot_input" value="' + (valKg ? valKg.replace(/,/g, '') : 0) + '">');
                            $form.append('<input type="hidden" name="lotUsages[' + idx + '].g" class="dynamic_lot_input" value="' + (valG ? valG.replace(/,/g, '') : 0) + '">');
                            $form.append('<input type="hidden" name="lotUsages[' + idx + '].mg" class="dynamic_lot_input" value="' + (valMg ? valMg.replace(/,/g, '') : 0) + '">');
                            idx++;
                        }

                        totalT += parseFloat((valT || "0").replace(/,/g, '')) || 0;
                        totalKg += parseFloat((valKg || "0").replace(/,/g, '')) || 0;
                        totalG += parseFloat((valG || "0").replace(/,/g, '')) || 0;
                        totalMg += parseFloat((valMg || "0").replace(/,/g, '')) || 0;
                    });

                    $("form.raw input[name='out_qty_t']").val(totalT > 0 ? totalT.toLocaleString('en-US') : "");
                    $("form.raw input[name='out_qty_kg']").val(totalKg > 0 ? totalKg.toLocaleString('en-US') : "");
                    $("form.raw input[name='out_qty_g']").val(totalG > 0 ? totalG.toLocaleString('en-US') : "");
                    $("form.raw input[name='out_qty_mg']").val(totalMg > 0 ? totalMg.toLocaleString('en-US') : "");

                    $("#itemLotPopup").hide();
                });

                //■■■■■■제품■■■■■■

                // 제품 Lot번호 input 클릭/포커스 시 레이어 팝업 표시
                $("form.product input[name='lot_number']").on("click focus", function () {
                    let productName = $("#product_item_name").val().trim();

                    if (productName !== "") {
                        $.ajax({
                            url: "getItemLots.jsp",
                            type: "GET",
                            data: { item_name: productName, category: "PRODUCT" },
                            dataType: "json",
                            success: function (lotList) {
                                let $ul = $("#product_lot_list_ul");
                                $ul.empty();

                                if (!lotList || lotList.length === 0) {
                                    $ul.html('<li style="text-align:center; padding: 15px;">등록된 Lot이 없습니다.</li>');
                                } else {
                                    $.each(lotList, function (idx, item) {
                                        let currentQty = item.stock_qty || 0;
                                        let formattedQty = formatNumberAuto(currentQty);
                                        let saved = productUseLotMap.get(item.lot_number) || { qty: '' };

                                        let html = '<li>'
                                            + '    <dl class="lot">'
                                            + '        <dt>Lot번호</dt>'
                                            + '        <dd>' + item.lot_number + '</dd>'
                                            + '    </dl>'
                                            + '    <dl class="stock">'
                                            + '        <dt>현재재고</dt>'
                                            + '        <dd><i>' + formattedQty + '</i>개</dd>'
                                            + '    </dl>'
                                            + '    <dl class="volume">'
                                            + '        <dt>출고개수 <button type="button" class="btn_product_all_use" data-qty="' + currentQty + '">전체출고</button></dt>'
                                            + '        <dd><input type="text" class="inputText lot_qty_input" data-lot="' + item.lot_number + '" value="' + saved.qty + '" inputmode="decimal"><i>개</i></dd>'
                                            + '    </dl>'
                                            + '</li>';
                                        $ul.append(html);
                                    });
                                }
                                $("#productLotPopup").show();
                            },
                            error: function (xhr, status, error) {
                                console.error("Error:", error);
                                alert("Lot 목록을 불러오는 중 오류가 발생했습니다.");
                            }
                        });
                    }
                });

                // 제품 전체출고 버튼
                $(document).on("click", ".btn_product_all_use", function () {
                    let $li = $(this).closest("li");
                    let qty = $(this).attr("data-qty");
                    $li.find(".lot_qty_input").val(Number(qty) > 0 ? Number(qty).toLocaleString('en-US') : "");
                });

                // 제품 팝업 [적용] 버튼
                $(document).on("click", "#btn_product_apply_lots", function () {
                    let totalQty = 0;
                    productUseLotMap.clear();
                    $("form.product input.dynamic_lot_input").remove();
                    let $form = $("form.product");
                    let idx = 0;

                    $("#productLotPopup #product_lot_list_ul li").each(function () {
                        let $li = $(this);
                        let lotNumber = $li.find(".lot dd").text().trim();
                        let valQty = $li.find(".lot_qty_input").val();

                        if (valQty) {
                            productUseLotMap.set(lotNumber, { qty: valQty });
                            $form.append('<input type="hidden" name="lotUsages[' + idx + '].lot_number" class="dynamic_lot_input" value="' + lotNumber + '">');
                            $form.append('<input type="hidden" name="lotUsages[' + idx + '].qty" class="dynamic_lot_input" value="' + valQty.replace(/,/g, '') + '">');
                            idx++;
                        }

                        totalQty += parseFloat((valQty || "0").replace(/,/g, '')) || 0;
                    });

                    $("form.product input[name='out_qty']").val(totalQty > 0 ? totalQty.toLocaleString('en-US') : "");
                    $("#productLotPopup").hide();
                });

                // 수량 단위 자동 환산 관련 로직 (원료 전용)
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

                    // 제품 폼인 경우 단위 환산 로직 스킵
                    if ($this.closest('form').hasClass('product')) {
                        return;
                    }

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
                    
                    if ($userInput && $userInput.length > 0 && !$(this).hasClass('product')) {
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