<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content registPage totalReg">
                <div class="title_set">
                    <h5 class="page_tit"><p>입고등록</p></h5>
                </div>
                <div class="top_control">
                    <button type="button" class="raw on" data-target="raw">원료</button>
                    <button type="button" class="product" data-target="product">제품</button>
                    <button type="button" class="subsidiary" data-target="subsidiary">부자재</button>
                </div>
                <!--원료-->
                <form class="raw" action="receivingRegistAction.jsp" method="post" style="display: block;">
                    <input type="hidden" name="category" value="RAW">
                    <section class="radius">
                        <dl>
                            <dt>원료명</dt>
                            <dd><input type="text" id="raw_item_name" name="item_name" class="inputText" placeholder="원료명 입력 (자동완성)"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>Lot번호</dt>
                            <dd><input type="text" name="lot_number" class="inputText" placeholder="Lot 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>입고일</dt>
                            <dd><input type="date" name="receipt_date" class="inputText"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조일</dt>
                            <dd><input type="date" name="manufacture_date" class="inputText"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>EXP</dt>
                            <dd><input type="date" name="expiration_date" class="inputText"></dd>
                        </dl>
                        <dl class="volume stock">
                            <dt>입고물량</dt>
                            <dd>
                                <div class="unit_t"><input type="text" name="in_qty_t" class="inputText" inputmode="decimal"><i>t</i></div>
                                <div class="unit_kg"><input type="text" name="in_qty_kg" class="inputText" inputmode="decimal"><i>kg</i></div>
                                <div class="unit_g"><input type="text" name="in_qty_g" class="inputText" inputmode="decimal"><i>g</i></div>
                                <div class="unit_mg"><input type="text" name="in_qty_mg" class="inputText" inputmode="decimal"><i>mg</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="180" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="180">입고등록</button>
                        </div>
                    </section>
                </form>
                <!--//원료-->
                <!--제품-->
                <form class="product" action="receivingRegistAction.jsp" method="post">
                    <input type="hidden" name="category" value="PRODUCT">
                    <section class="radius">
                        <dl class="w75">
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
                        <dl class="w25">
                            <dt>제조일</dt>
                            <dd><input type="date" name="manufacture_date" class="inputText"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>EXP</dt>
                            <dd><input type="date" name="expiration_date" class="inputText"></dd>
                        </dl>
                        <dl class="volume stock w25">
                            <dt>등록개수</dt>
                            <dd>
                                <div class="unit_ea"><input type="text" name="in_qty" class="inputText" inputmode="decimal"><i>개</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="180" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="180">입고등록</button>
                        </div>
                    </section>
                </form>
                <!--//제품-->
                <!--부자재-->
                <form class="subsidiary" action="receivingRegistAction.jsp" method="post">
                    <input type="hidden" name="category" value="SUBSIDIARY">
                    <section class="radius">
                        <dl class="w25">
                            <dt>자재명</dt>
                            <dd><input type="text" id="sub_item_name" name="item_name" class="inputText" placeholder="자재명 입력 (자동완성)"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>종류</dt>
                            <dd>
                                <select class="og_select" name="subsidiary_type">
                                    <option value="">선택</option>
                                    <option value="Label">Label</option>
                                    <option value="Bottle">Bottle</option>
                                    <option value="Pump">Pump</option>
                                    <option value="Cap">Cap</option>
                                    <option value="Box">Box</option>
                                    <option value="기타">기타</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>재질</dt>
                            <dd>
                                <select class="og_select" name="material_type">
                                    <option value="">선택</option>
                                    <option value="종이">종이</option>
                                    <option value="플라스틱">플라스틱</option>
                                    <option value="유리">유리</option>
                                    <option value="기타">기타</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="volume stock w25">
                            <dt>등록개수</dt>
                            <dd>
                                <div class="unit_ea"><input type="text" name="in_qty" class="inputText" inputmode="decimal"><i>개</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="180" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="180">입고등록</button>
                        </div>
                    </section>
                </form>
                <!--//부자재-->
            </div>
        </div>
        <script>
            $(document).ready(function() {
                // 품목명 Autocomplete 및 종류/재질 자동 선택
                function setupAutocomplete(elementId, categoryName) {
                    $(elementId).autocomplete({
                        source: function (request, response) {
                            $.ajax({
                                url: "searchItems.jsp",
                                type: "GET",
                                data: {
                                    category: categoryName,
                                    keyword: request.term
                                },
                                dataType: "json",
                                success: function (data) {
                                    // 서버 응답 데이터를 콘솔에서 확인 (F12 콘솔 탭 참고)
                                    console.log("Autocomplete 응답 데이터:", data);

                                    // 문자열 배열 또는 객체 배열 모두 대응 가능하도록 변환
                                    response($.map(data, function (item) {
                                        if (typeof item === 'string') {
                                            return { label: item, value: item };
                                        } else {
                                            return {
                                                label: item.label || item.item_name, // 서버의 키 값에 맞춰 조정
                                                value: item.value || item.item_name,
                                                type: item.type,
                                                material: item.material
                                            };
                                        }
                                    }));
                                },
                                error: function (jqXHR, textStatus, errorThrown) {
                                    console.error("Autocomplete 오류:", textStatus, errorThrown);
                                }
                            });
                        },
                        minLength: 1,
                        appendTo: ".registPage", // 목록이 CSS 레이어 뒤로 숨겨지는 현상 방지
                        select: function (event, ui) {
                            const $form = $(this).closest('form');

                            if (categoryName === "PRODUCT" && ui.item.type) {
                                $form.find("select[name='product_type']").val(ui.item.type).trigger('change');
                            }

                            if (categoryName === "SUBSIDIARY") {
                                if (ui.item.type) {
                                    $form.find("select[name='subsidiary_type']").val(ui.item.type).trigger('change');
                                }
                                if (ui.item.material) {
                                    $form.find("select[name='material_type']").val(ui.item.material).trigger('change');
                                }
                            }
                        }
                    });
                }

                setupAutocomplete("#raw_item_name", "RAW");
                setupAutocomplete("#product_item_name", "PRODUCT");
                setupAutocomplete("#sub_item_name", "SUBSIDIARY");

                // Lot 번호 Autocomplete
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
                        minLength: 1
                    });
                }

                setupLotAutocomplete("form.raw input[name='lot_number']", "#raw_item_name", "RAW");
                setupLotAutocomplete("form.product input[name='lot_number']", "#product_item_name", "PRODUCT");

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
                    
                    if (!$parentDiv.hasClass('unit_ea')) {
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
                    }
                });

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