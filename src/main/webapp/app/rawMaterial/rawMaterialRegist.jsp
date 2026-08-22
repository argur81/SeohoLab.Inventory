<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content registPage">
                <div class="title_set">
                    <h5 class="page_tit"><p>신규등록</p><i><img src="/images/svg/location_arrow.svg"></i><b>원료</b></h5>
                </div>
                <form id="regForm" action="rawMaterialRegistAction.jsp" method="post">
                    <input type="hidden" name="category" value="RAW">
                    <section class="radius">
                        <dl class="w25">
                            <dt>원료코드</dt>
                            <dd><input type="text" name="item_code" class="inputText" placeholder="원료코드 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>상품명 (Trade Name)</dt>
                            <dd><input type="text" name="item_name" class="inputText" placeholder="상품명 입력" required></dd>
                        </dl>
                        <dl class="w25">
                            <dt>작업 지시서명1</dt>
                            <dd><input type="text" name="work_order_1" class="inputText" placeholder="작업 지시서명1 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>작업 지시서명2</dt>
                            <dd><input type="text" name="work_order_2" class="inputText" placeholder="작업 지시서명2 입력"></dd>
                        </dl>
                        
                        <dl class="w25">
                            <dt>화학명(한글)</dt>
                            <dd><input type="text" name="chem_name" class="inputText" placeholder="화학명 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>INCI Name</dt>
                            <dd><input type="text" name="inci_name" class="inputText" placeholder="INCI Name 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>CAS No.</dt>
                            <dd><input type="text" name="cas_no" class="inputText" placeholder="CAS No. 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>공급업체</dt>
                            <dd><input type="text" name="supplier" class="inputText" placeholder="공급업체 입력"></dd>
                        </dl>

                        <dl class="w25">
                            <dt>제조사</dt>
                            <dd><input type="text" name="maker" class="inputText" placeholder="제조사 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>단가구분</dt>
                            <dd>
                                <select name="price_type" id="priceTypeSelect" class="og_select">
                                    <option value="1kg·1g 당">1kg·1g 당</option>
                                    <option value="무게당 입력">무게당 입력</option>
                                    <option value="가격대">가격대</option>
                                    <option value="기타">기타</option>
                                </select>
                            </dd>
                        </dl>

                        <!-- 단가 항목 (무게당 입력일 때 w100, 그 외 w25) -->
                        <dl class="w25" id="priceDl">
                            <dt>단가</dt>
                            <dd>
                                <!-- 1. 1kg·1g 당 -->
                                <div class="price_div direct" style="display:none;">
                                    <input type="text" name="price" id="priceInput" class="inputText" placeholder="숫자 단가 입력" inputmode="decimal">
                                </div>

                                <!-- 2. 무게당 입력 (4개 세트) -->
                                <div class="price_div kg_enter" style="display:none;">
                                    <ul>
                                        <li>
                                            <p>
                                                <input type="text" name="kg_qty_1" class="inputText" placeholder="숫자 입력" inputmode="decimal">
                                                <select name="kg_unit_1" class="og_select">
                                                    <option>t</option>
                                                    <option selected>kg</option>
                                                    <option>g</option>
                                                    <option>mg</option>
                                                </select>
                                            </p>
                                            <div><input type="text" name="kg_price_1" class="inputText" placeholder="숫자 입력" inputmode="decimal"></div>
                                        </li>
                                        <li>
                                            <p>
                                                <input type="text" name="kg_qty_2" class="inputText" placeholder="숫자 입력" inputmode="decimal">
                                                <select name="kg_unit_2" class="og_select">
                                                    <option>t</option>
                                                    <option selected>kg</option>
                                                    <option>g</option>
                                                    <option>mg</option>
                                                </select>
                                            </p>
                                            <div><input type="text" name="kg_price_2" class="inputText" placeholder="숫자 입력" inputmode="decimal"></div>
                                        </li>
                                        <li>
                                            <p>
                                                <input type="text" name="kg_qty_3" class="inputText" placeholder="숫자 입력" inputmode="decimal">
                                                <select name="kg_unit_3" class="og_select">
                                                    <option>t</option>
                                                    <option selected>kg</option>
                                                    <option>g</option>
                                                    <option>mg</option>
                                                </select>
                                            </p>
                                            <div><input type="text" name="kg_price_3" class="inputText" placeholder="숫자 입력" inputmode="decimal"></div>
                                        </li>
                                        <li>
                                            <p>
                                                <input type="text" name="kg_qty_4" class="inputText" placeholder="숫자 입력" inputmode="decimal">
                                                <select name="kg_unit_4" class="og_select">
                                                    <option>t</option>
                                                    <option selected>kg</option>
                                                    <option>g</option>
                                                    <option>mg</option>
                                                </select>
                                            </p>
                                            <div><input type="text" name="kg_price_4" class="inputText" placeholder="숫자 입력" inputmode="decimal"></div>
                                        </li>
                                    </ul>
                                </div>

                                <!-- 3. 가격대 입력 -->
                                <div class="price_div price_range" style="display:none;">
                                    <input type="text" name="price_range" class="inputText" placeholder="가격대 입력 (예: 10,000 ~ 20,000)" inputmode="decimal">
                                </div>

                                <!-- 4. 기타 입력 -->
                                <div class="price_div etc_price" style="display:none;">
                                    <input type="text" name="price_etc" class="inputText" placeholder="(예: 인상이슈, 가격인상 등)">
                                </div>
                            </dd>
                        </dl>
                        <dl class="w100">
                            <dt>원료추가정보</dt>
                            <dd>
                                <textarea class="textArea" name="extra_info" placeholder="원료추가정보 입력"></textarea>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>Function</dt>
                            <dd>
                                <textarea class="textArea input_size" name="func" placeholder="Function 입력"></textarea>
                            </dd>
                        </dl>
                        <!-- Packing 단위 (input + select 조합) -->
                        <dl class="w25">
                            <dt>Packing 단위</dt>
                            <dd class="has_input-select">
                                <input type="text" name="packing_unit" class="inputText" placeholder="Packing 단위 입력">
                                <select name="packing_unit_select" class="og_select">
                                    <option>t</option>
                                    <option selected>kg</option>
                                    <option>g</option>
                                    <option>mg</option>
                                    <option>Drum</option>
                                    <option>ℓ</option>
                                    <option>기타</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>rHLB</dt>
                            <dd><input type="text" name="r_hlb" class="inputText" placeholder="rHLB 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>HLB</dt>
                            <dd><input type="text" name="hlb" class="inputText" placeholder="HLB 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>인증</dt>
                            <dd><input type="text" name="certification" class="inputText" placeholder="인증 정보 입력"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>유래</dt>
                            <dd><textarea name="origin" class="textArea input_size" placeholder="유래 입력"></textarea></dd>
                        </dl>
                        <dl class="w25">
                            <dt>특이사항</dt>
                            <dd><textarea name="note" class="textArea input_size" placeholder="특이사항 입력"></textarea></dd>
                        </dl>
                        <dl class="w25">
                            <dt>연구실명칭</dt>
                            <dd><input type="text" name="lab_name" class="inputText" placeholder="연구실명칭 입력"></dd>
                        </dl>
                        <dl class="volume min">
                            <dt>최소 재고물량</dt>
                            <dd>
                                <div class="unit_t"><input type="text" name="min_qty_t" class="inputText" inputmode="decimal"><i>t</i></div>
                                <div class="unit_kg"><input type="text" name="min_qty_kg" class="inputText" inputmode="decimal"><i>kg</i></div>
                                <div class="unit_g"><input type="text" name="min_qty_g" class="inputText" inputmode="decimal"><i>g</i></div>
                                <div class="unit_mg"><input type="text" name="min_qty_mg" class="inputText" inputmode="decimal"><i>mg</i></div>
                            </dd>
                        </dl>

                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="100" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="100">등록</button>
                        </div>
                    </section>
                </form>
            </div>
        </div>
        <script>
           $(document).ready(function() {
                // 단위별 그램 환산 계수 (최소 재고물량 계산용)
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

                // 단가구분 변경 이벤트 (무게당 입력일 때 w100, 그 외 w25 및 해당 div 토글)
                $('#priceTypeSelect').on('change', function() {
                    let selectedVal = $(this).val();
                    let $priceDl = $('#priceDl');

                    // 모든 단가 입력 div 숨기기 및 비활성화 처리
                    $priceDl.find('.price_div').hide();
                    $priceDl.find('input').prop('disabled', true);

                    if (selectedVal === '1kg·1g 당') {
                        $priceDl.removeClass('w100').addClass('w25');
                        let $target = $priceDl.find('.direct');
                        $target.show();
                        $target.find('input').prop('disabled', false);
                    } else if (selectedVal === '무게당 입력') {
                        $priceDl.removeClass('w25').addClass('w100');
                        let $target = $priceDl.find('.kg_enter');
                        $target.show();
                        $target.find('input').prop('disabled', false);
                    } else if (selectedVal === '가격대') {
                        $priceDl.removeClass('w100').addClass('w25');
                        let $target = $priceDl.find('.price_range');
                        $target.show();
                        $target.find('input').prop('disabled', false);
                    } else if (selectedVal === '기타') {
                        $priceDl.removeClass('w100').addClass('w25');
                        let $target = $priceDl.find('.etc_price');
                        $target.show();
                        $target.find('input').prop('disabled', false);
                    }
                });

                // 최초 로드 시 초기 상태 설정
                $('#priceTypeSelect').trigger('change');

                // 모든 inputmode="decimal" 필드에 대해 실시간 콤마 및 최소 재고물량 연동 계산 처리
                $(document).on('input', 'input[inputmode="decimal"]', function() {
                    let $this = $(this);
                    if ($this.is(':disabled')) return;

                    let value = $this.val().replace(/[^0-9.]/g, '');
                    const parts = value.split('.');
                    if (parts.length > 2) value = parts[0] + '.' + parts.slice(1).join('');

                    $this.val(formatWithComma(value));

                    // 최소 재고물량(dl.min) 영역 안의 입력창인 경우에만 단위 연동 계산 수행
                    if ($this.closest('dl').hasClass('min')) {
                        const $parentGroup = $this.closest('dl');
                        const currentUnitClass = $this.parent('div').attr('class').split(' ').find(cls => cls.startsWith('unit_'));

                        if (!value || value === '.') {
                            $parentGroup.find('input[inputmode="decimal"]').not($this).val('');
                            return;
                        }

                        const numValue = parseFloat(value.replace(/,/g, ''));
                        if (isNaN(numValue)) return;

                        const baseGrams = numValue * unitToGram[currentUnitClass];

                        $.each(unitToGram, function(unitClass, ratio) {
                            if (unitClass !== currentUnitClass) {
                                let calculated = baseGrams / ratio;
                                let calcStr = Number(calculated.toFixed(6)).toString(); 
                                $parentGroup.find('.' + unitClass + ' input').val(formatWithComma(calcStr));
                            }
                        });
                    }
                });

                // 폼 제출 전 콤마 제거 및 비활성화되지 않은 decimal 입력창 정리
                $('#regForm').on('submit', function () {
                    $(this).find('input[inputmode="decimal"]').not(':disabled').each(function () {
                        let rawVal = $(this).val().replace(/,/g, '');
                        if(rawVal === '') rawVal = '0';
                        $(this).val(rawVal);
                    });
                });
            });
        </script>
    </div>
<jsp:include page="/app/include/FooterDocType.jsp" />