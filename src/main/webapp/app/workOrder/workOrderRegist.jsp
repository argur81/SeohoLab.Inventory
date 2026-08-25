<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    // 한글 인코딩 설정
    request.setCharacterEncoding("UTF-8");

    // 수정 또는 임시저장 불러오기용 order_id 파라미터 수신
    String orderIdStr = request.getParameter("order_id");
    int orderId = 0;
    if (orderIdStr != null && !orderIdStr.trim().isEmpty()) {
        try {
            orderId = Integer.parseInt(orderIdStr);
        } catch (NumberFormatException e) {
            orderId = 0;
        }
    }

    // DB 연결 정보 설정 (MariaDB)
    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    // 마스터 정보 변수 선언
    String productName = "";
    String targetQty = "";
    String targetUnit = "kg";
    String managerName = "박소희";
    String machine = "AGI Mixer";
    String appearance = "";
    String scent = "";
    String specificGravity = "";
    String ph = "";
    String theorQty = "";
    String theorUnit = "kg";
    String yieldRate = "";
    String yieldStandard = "";
    String status = "NORMAL";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    if (orderId > 0) {
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            conn = DriverManager.getConnection(url, dbUser, dbPass);

            String masterSql = "SELECT * FROM work_orders WHERE order_id = ?";
            pstmt = conn.prepareStatement(masterSql);
            pstmt.setInt(1, orderId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                productName = rs.getString("product_name") != null ? rs.getString("product_name") : "";
                targetQty = rs.getString("target_qty") != null ? rs.getString("target_qty") : "";
                targetUnit = rs.getString("target_unit") != null ? rs.getString("target_unit") : "kg";
                managerName = rs.getString("manager_name") != null ? rs.getString("manager_name") : "박소희";
                machine = rs.getString("machine") != null ? rs.getString("machine") : "AGI Mixer";
                appearance = rs.getString("appearance") != null ? rs.getString("appearance") : "";
                scent = rs.getString("scent") != null ? rs.getString("scent") : "";
                specificGravity = rs.getString("specific_gravity") != null ? rs.getString("specific_gravity") : "";
                ph = rs.getString("ph") != null ? rs.getString("ph") : "";
                theorQty = rs.getString("theor_qty") != null ? rs.getString("theor_qty") : "";
                theorUnit = rs.getString("theor_unit") != null ? rs.getString("theor_unit") : "kg";
                yieldRate = rs.getString("yield_rate") != null ? rs.getString("yield_rate") : "";
                yieldStandard = rs.getString("yield_standard") != null ? rs.getString("yield_standard") : "";
                status = rs.getString("status") != null ? rs.getString("status") : "NORMAL";
            }
            rs.close();
            pstmt.close();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content workOrderList">
                <div class="title_set">
                    <h5 class="page_tit">
                        <p>제조 지시서</p>
                        <i><img src="/images/svg/location_arrow.svg"></i>
                        <b>관리·신규등록</b>
                        <i><img src="/images/svg/location_arrow.svg"></i>
                        <%= (orderId == 0) ? "신규등록" : "수정" %>
                    </h5>
                </div>
                <form id="regForm" method="post" action="<%= (orderId == 0) ? "workOrderRegistAction.jsp" : "workOrderTempSaveAction.jsp" %>">
                    <input type="hidden" name="order_id" value="<%= orderId %>">

                    <section class="radius">
                        <dl class="w50">
                            <dt>제품명</dt>
                            <dd><input type="text" name="product_name" class="inputText" placeholder="제품명 입력" value="<%= productName %>" required></dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조지시량</dt>
                            <dd class="has_input-select">
                                <input type="text" name="target_qty" class="inputText top-target-qty" inputmode="decimal" value="<%= targetQty %>">
                                <select name="target_unit" class="og_select top-target-unit">
                                    <option value="kg" <%= "kg".equals(targetUnit) ? "selected" : "" %>>kg</option>
                                    <option value="g" <%= "g".equals(targetUnit) ? "selected" : "" %>>g</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조지시자</dt>
                            <dd><input type="text" name="manager_name" class="inputText" value="<%= managerName %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조기기</dt>
                            <dd>
                                <select name="machine" class="og_select">
                                    <option value="AGI Mixer" <%= "AGI Mixer".equals(machine) ? "selected" : "" %>>AGI Mixer</option>
                                    <option value="Homo Mixer" <%= "Homo Mixer".equals(machine) ? "selected" : "" %>>Homo Mixer</option>
                                    <option value="AGI Mixer, Homo Mixer" <%= "AGI Mixer, Homo Mixer".equals(machine) ? "selected" : "" %>>AGI Mixer, Homo Mixer</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>성상</dt>
                            <dd><input type="text" name="appearance" class="inputText" value="<%= appearance %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>향취</dt>
                            <dd><input type="text" name="scent" class="inputText" value="<%= scent %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>비중</dt>
                            <dd><input type="text" name="specific_gravity" class="inputText" value="<%= specificGravity %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>pH</dt>
                            <dd><input type="text" name="ph" class="inputText" value="<%= ph %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>이론제조량</dt>
                            <dd class="has_input-select">
                                <input type="text" name="theor_qty" class="inputText" inputmode="decimal" value="<%= theorQty %>">
                                <select name="theor_unit" class="og_select">
                                    <option value="kg" <%= "kg".equals(theorUnit) ? "selected" : "" %>>kg</option>
                                    <option value="g" <%= "g".equals(theorUnit) ? "selected" : "" %>>g</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조수율</dt>
                            <dd><input type="text" name="yield_rate" class="inputText" placeholder="제조수율 = (실제제조량/이론제조량) * 100" value="<%= yieldRate %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조수율 기준</dt>
                            <dd><input type="text" name="yield_standard" class="inputText" value="<%= yieldStandard %>"></dd>
                        </dl>
                    </section>

                    <!-- 하단 원료 투입 목록 섹션 -->
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
<%
    boolean hasItems = false;
    if (orderId > 0) {
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            conn = DriverManager.getConnection(url, dbUser, dbPass);
            String itemSql = "SELECT * FROM work_order_items WHERE order_id = ? ORDER BY item_row_id ASC";
            pstmt = conn.prepareStatement(itemSql);
            pstmt.setInt(1, orderId);
            rs = pstmt.executeQuery();

            int itemIdx = 1;
            while (rs.next()) {
                hasItems = true;
%>
                                <tr>
                                    <td data-roll="No">
                                        <span class="row-num"><%= itemIdx %></span>
                                        <% if (itemIdx > 1) { %>
                                        <button type="button" class="delRowBtn" title="삭제">삭제</button>
                                        <% } %>
                                    </td>
                                    <td data-roll="원료명"><input type="text" name="raw_material_name" class="inputText item-autocomplete" placeholder="원료명 입력" value="<%= rs.getString("raw_material_name") != null ? rs.getString("raw_material_name") : "" %>"></td>
                                    <td data-roll="원료시험번호"><input type="text" name="test_number" class="inputText" value="<%= rs.getString("test_number") != null ? rs.getString("test_number") : "" %>"></td>
                                    <td data-roll="함량(%)"><div class="unit"><input type="text" name="content_pct" class="inputText row-content-pct" inputmode="decimal" value="<%= rs.getString("content_pct") %>"><i>%</i></div></td>
                                    <td data-roll="제조지시량(kg)"><div class="unit"><input type="text" name="order_qty_kg" class="inputText order-kg" inputmode="decimal" value="<%= rs.getString("order_qty_kg") %>"><i>kg</i></div></td>
                                    <td data-roll="제조지시량(g)"><div class="unit"><input type="text" name="order_qty_g" class="inputText order-g" inputmode="decimal" value="<%= rs.getString("order_qty_g") %>"><i>g</i></div></td>
                                    <td data-roll="단가"><div class="unit"><input type="text" name="unit_price" class="inputText item-price" inputmode="decimal" value="<%= rs.getString("unit_price") %>"><i>원</i></div></td>
                                </tr>
<%
                itemIdx++;
            }
            rs.close();
            pstmt.close();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }

    if (!hasItems) {
%>
                                <tr>
                                    <td data-roll="No">
                                        <span class="row-num">1</span>
                                    </td>
                                    <td data-roll="원료명"><input type="text" name="raw_material_name" class="inputText item-autocomplete" placeholder="원료명 입력"></td>
                                    <td data-roll="원료시험번호"><input type="text" name="test_number" class="inputText"></td>
                                    <td data-roll="함량(%)"><div class="unit"><input type="text" name="content_pct" class="inputText row-content-pct" inputmode="decimal"><i>%</i></div></td>
                                    <td data-roll="제조지시량(kg)"><div class="unit"><input type="text" name="order_qty_kg" class="inputText order-kg" inputmode="decimal"><i>kg</i></div></td>
                                    <td data-roll="제조지시량(g)"><div class="unit"><input type="text" name="order_qty_g" class="inputText order-g" inputmode="decimal"><i>g</i></div></td>
                                    <td data-roll="단가"><div class="unit"><input type="text" name="unit_price" class="inputText item-price" inputmode="decimal"><i>원</i></div></td>
                                </tr>
<%
    }
%>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td colspan="3">합계</td>
                                    <td data-roll="합계 : 함량(%)"><div class="unit"><input type="text" name="total_content_pct" class="inputText total-pct" inputmode="decimal" readonly><i>%</i></div></td>
                                    <td data-roll="합계 : 제조지시량(kg)"><div class="unit"><input type="text" name="total_kg" class="inputText total-kg" inputmode="decimal" readonly><i>kg</i></div></td>
                                    <td data-roll="합계 : 제조지시량(g)"><div class="unit"><input type="text" name="total_g" class="inputText total-g" inputmode="decimal" readonly><i>g</i></div></td>
                                    <td data-roll="합계 : 단가"><div class="unit"><input type="text" name="total_price" class="inputText total-price" inputmode="decimal" readonly><i>원</i></div></td>
                                </tr>
                            </tfoot>
                        </table>
                        <div class="add_btn">
                            <button type="button" id="addRowBtn" class="Button">원료 행 추가</button>
                        </div>
                    </section>

                    <!-- 제조방법 및 상(Phase) 관리 섹션 -->
                    <section class="radius">
                        <table class="phase_table">
                            <colgroup>
                                <col width="100">
                                <col width="230">
                                <col width="auto">
                                <col width="auto">
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
<%
    boolean hasPhases = false;
    if (orderId > 0) {
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            conn = DriverManager.getConnection(url, dbUser, dbPass);
            String phaseSql = "SELECT * FROM work_order_phases WHERE order_id = ? ORDER BY phase_row_id ASC";
            pstmt = conn.prepareStatement(phaseSql);
            pstmt.setInt(1, orderId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                hasPhases = true;
%>
                                <tr>
                                    <th>
                                        <span class="phase-name"><%= rs.getString("phase_name") %></span>
                                        <input type="hidden" name="phase_title" value="<%= rs.getString("phase_name") %>" class="phase-title-input">
                                    </th>
                                    <td data-roll="선택">
                                        <div class="phase_num">
                                            <select name="phase_start" class="og_select phase-start-sel"></select>
                                            <i>~</i>
                                            <select name="phase_end" class="og_select phase-end-sel"></select>
                                        </div>
                                    </td>
                                    <td data-roll="제조방법">
                                        <textarea name="method_desc" class="textArea" placeholder="제조방법 입력"><%= rs.getString("method_desc") != null ? rs.getString("method_desc") : "" %></textarea>
                                    </td>
                                    <td data-roll="비고">
                                        <textarea name="note_desc" class="textArea" placeholder="비고 입력"><%= rs.getString("note_desc") != null ? rs.getString("note_desc") : "" %></textarea>
                                    </td>
                                </tr>
<%
            }
            rs.close();
            pstmt.close();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }

    if (!hasPhases) {
%>
                                <tr>
                                    <th>
                                        <span class="phase-name">A상</span><input type="hidden" name="phase_title" value="A상" class="phase-title-input">
                                    </th>
                                    <td data-roll="선택">
                                        <div class="phase_num">
                                            <select name="phase_start" class="og_select phase-start-sel"></select>
                                            <i>~</i>
                                            <select name="phase_end" class="og_select phase-end-sel"></select>
                                        </div>
                                    </td>
                                    <td data-roll="제조방법">
                                        <textarea name="method_desc" class="textArea" placeholder="제조방법 입력"></textarea>
                                    </td>
                                    <td data-roll="비고">
                                        <textarea name="note_desc" class="textArea" placeholder="비고 입력"></textarea>
                                    </td>
                                </tr>
<%
    }
%>
                            </tbody>
                        </table>
                        <div class="add_btn">
                            <button type="button" id="addPhaseBtn" class="Button">추가</button>
                        </div>
                    </section>

                    <div class="bottom_btns">
                        <button type="button" class="Button bgGray" data-width="180" onclick="history.back();">취소</button>
                        <button type="button" id="tempSaveBtn" class="Button brdrYellow" data-width="180">임시저장</button>
                        <button type="submit" class="Button bgBlue" data-width="180"><%= (orderId == 0) ? "신규등록" : "수정완료" %></button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        function formatWithComma(value) {
            if (!value && value !== 0) return "";
            let parts = value.toString().split('.');
            parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
            return parts.join('.');
        }

        function getTopTargetGrams() {
            let val = parseFloat($(".top-target-qty").val().replace(/,/g, '')) || 0;
            let unit = $(".top-target-unit").val();
            if (unit === 'kg') {
                return val * 1000; // 정밀 계산을 위해 소수점 포함 유지
            } else {
                return val;
            }
        }

        function calculateRowPrice($row) {
            let priceType = $row.find('.item-price').data('price-type') || '1kg기준';
            let basePrice = parseFloat($row.find('.item-price').data('base-price')) || parseFloat($row.find('.item-price').val().replace(/,/g, '')) || 0;
            let topTargetKg = getTopTargetGrams() / 1000;
            let topTargetGrams = getTopTargetGrams();
            let pct = parseFloat($row.find('.row-content-pct').val().replace(/,/g, '')) || 0;

            let calculatedPrice = 0;

            if (priceType === '1kg기준') {
                let rowKg = topTargetKg * (pct / 100);
                calculatedPrice = basePrice * rowKg;
            } else if (priceType === '1g기준') {
                let rowGrams = topTargetGrams * (pct / 100);
                calculatedPrice = basePrice * rowGrams;
            } else if (priceType === '무게별') {
                let rowKg = topTargetKg * (pct / 100);
                let q1 = parseFloat($row.find('.item-price').data('kg-qty-1')) || 0;
                let p1 = parseFloat($row.find('.item-price').data('kg-price-1')) || 0;
                if (q1 > 0 && p1 > 0) {
                    calculatedPrice = (p1 / q1) * rowKg;
                } else {
                    calculatedPrice = basePrice * rowKg;
                }
            } else {
                let rowKg = topTargetKg * (pct / 100);
                calculatedPrice = basePrice * rowKg;
            }

            if (calculatedPrice > 0 && pct > 0) {
                $row.find('.item-price').val(formatWithComma(Math.round(calculatedPrice)));
            } else if (pct === 0) {
                $row.find('.item-price').val('');
            }
        }

        // [수정된 재계산 함수: kg 소수점 한자리 추가 및 g 정밀도 4자리 확장 적용]
        function recalculateAllQuantities() {
            let topTargetGrams = getTopTargetGrams();
            let $rows = $(".order_table tbody tr");
            let totalRows = $rows.length;

            let totalPct = 0;
            let totalKg = 0;
            let totalG = 0;
            let totalPrice = 0;

            $rows.each(function (index) {
                let $row = $(this);
                let pct = parseFloat($row.find('.row-content-pct').val().replace(/,/g, '')) || 0;
                totalPct += pct;

                let rowGrams = 0;
                if (topTargetGrams > 0 && pct > 0) {
                    // g단위: 첨부이미지 기준보다 소수점 아래 4자리가 더 표현되도록 총 소수점 4~5자리까지 정밀 유지 (예: 12.1935 등)
                    rowGrams = (topTargetGrams * pct) / 100;
                    rowGrams = Math.round(rowGrams * 10000) / 10000; 
                }

                // kg단위: g을 1000으로 나누어 기존보다 소수점 자릿수를 한자리 더 확보 (예: 소수점 이하 4~5자리 확보)
                let rowKg = rowGrams / 1000;

                if (pct > 0 || rowGrams > 0) {
                    // g은 소수점 아래 4자리 정밀도 표시 (원하시는 콤마/소수점 형태 반영)
                    $row.find('.order-g').val(rowGrams > 0 ? formatWithComma(rowGrams.toFixed(4)) : "");
                    // kg은 기존보다 소수점 자릿수를 한자리 더 풍부하게 표시 (소수점 5자리 표현)
                    $row.find('.order-kg').val(rowKg > 0 ? rowKg.toFixed(5) : "");
                } else {
                    $row.find('.order-g').val("");
                    $row.find('.order-kg').val("");
                }

                totalKg += rowKg;
                totalG += rowGrams;

                calculateRowPrice($row);
                let price = parseFloat($row.find('.item-price').val().replace(/,/g, '')) || 0;
                totalPrice += price;
            });

            $(".order_table tfoot .total-pct").val(formatWithComma(Number(totalPct.toFixed(4))));
            
            // 합계 kg 및 g 도 정밀도 맞춤 표현
            $(".order_table tfoot .total-kg").val(formatWithComma(Math.round(totalKg)));
            $(".order_table tfoot .total-g").val(formatWithComma(totalG.toFixed(4)));
            $(".order_table tfoot .total-price").val(formatWithComma(Math.round(totalPrice)));
        }

        $(document).ready(function () {
            function initAutocomplete($elem) {
                $elem.autocomplete({
                    source: "getItemAutoComplete.jsp",
                    minLength: 1,
                    select: function (event, ui) {
                        let $row = $(this).closest('tr');
                        
                        $row.find('.item-price').data('price-type', ui.item.priceType);
                        $row.find('.item-price').data('base-price', ui.item.price);
                        $row.find('.item-price').data('kg-qty-1', ui.item.kgQty1);
                        $row.find('.item-price').data('kg-price-1', ui.item.kgPrice1);
                        
                        recalculateAllQuantities();
                    }
                });
            }

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

            function updateRowIndices() {
                $(".order_table tbody tr").each(function (index) {
                    $(this).find(".row-num").text(index + 1);
                });
                updateAllPhaseSelects();
            }

            initAutocomplete($(".item-autocomplete"));
            updatePhaseNamesAndDeletes();
            updateAllPhaseSelects();
            recalculateAllQuantities();

            $("#addRowBtn").on("click", function () {
                let newRow = `
                    <tr>
                        <td data-roll="No">
                            <span class="row-num"></span>
                            <button type="button" class="delRowBtn" title="삭제">삭제</button>
                        </td>
                        <td data-roll="원료명"><input type="text" name="raw_material_name" class="inputText item-autocomplete" placeholder="원료명 입력"></td>
                        <td data-roll="원료시험번호"><input type="text" name="test_number" class="inputText"></td>
                        <td data-roll="함량(%)"><div class="unit"><input type="text" name="content_pct" class="inputText row-content-pct" inputmode="decimal"><i>%</i></div></td>
                        <td data-roll="제조지시량(kg)"><div class="unit"><input type="text" name="order_qty_kg" class="inputText order-kg" inputmode="decimal"><i>kg</i></div></td>
                        <td data-roll="제조지시량(g)"><div class="unit"><input type="text" name="order_qty_g" class="inputText order-g" inputmode="decimal"><i>g</i></div></td>
                        <td data-roll="단가"><div class="unit"><input type="text" name="unit_price" class="inputText item-price" inputmode="decimal"><i>원</i></div></td>
                    </tr>
                `;
                $(".order_table tbody").append(newRow);
                
                updateRowIndices();
                initAutocomplete($(".order_table tbody tr:last-child .item-autocomplete"));
                recalculateAllQuantities();
            });

            $(document).on("click", ".delRowBtn", function () {
                $(this).closest("tr").remove();
                updateRowIndices();
                recalculateAllQuantities();
            });

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
                        <td data-roll="선택">
                            <div class="phase_num">
                                <select name="phase_start" class="og_select phase-start-sel">` + optionsHtml + `</select>
                                <i>~</i>
                                <select name="phase_end" class="og_select phase-end-sel">` + optionsHtml + `</select>
                            </div>
                        </td>
                        <td data-roll="제조방법">
                            <textarea name="method_desc" class="textArea" placeholder="제조방법 입력"></textarea>
                        </td>
                        <td data-roll="비고">
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

            $(document).on("click", ".delPhaseBtn", function () {
                $(this).closest("tr").remove();
                updatePhaseNamesAndDeletes();
                updateAllPhaseSelects();
            });

            $(document).on("change", ".phase-end-sel", function () {
                updateAllPhaseSelects();
            });

            $(document).on('input', 'input[name="target_qty"], input[name="theor_qty"]', function() {
                let $this = $(this);
                let value = $this.val().replace(/[^0-9.]/g, '');
                let parts = value.split('.');
                if (parts.length > 2) value = parts[0] + '.' + parts.slice(1).join('');

                $this.val(formatWithComma(value));
            });

            $(document).on('input change', '.top-target-qty, .top-target-unit', function() {
                recalculateAllQuantities();
            });

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

                if (enteredVal > maxAllowedPct + 0.0001) {
                    alert("함량(%)의 총합은 100%를 초과할 수 없습니다. (최대 입력 가능: " + maxAllowedPct + "%)");
                    enteredVal = maxAllowedPct;
                    value = enteredVal.toString();
                }

                $this.val(formatWithComma(value));
                recalculateAllQuantities();
            });

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
                    $row.find('.row-content-pct').val('');
                    recalculateAllQuantities();
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

                    if (currentGrams > maxAllowedGrams + 0.001) {
                        alert("합계 제조지시량은 상단의 제조지시량(" + $(".top-target-qty").val() + " " + $(".top-target-unit").val() + ")을 초과할 수 없습니다.");
                        if ($this.hasClass('order-kg')) {
                            numValue = maxAllowedGrams / 1000;
                        } else {
                            numValue = maxAllowedGrams;
                        }
                        value = Number(numValue.toFixed(5)).toString();
                    }
                }

                let currentGramsForCalc = $this.hasClass('order-kg') ? (numValue * 1000) : numValue;
                if (topLimitGrams > 0) {
                    let calculatedPct = (currentGramsForCalc / topLimitGrams) * 100;
                    $row.find('.row-content-pct').val(formatWithComma(Number(calculatedPct.toFixed(4))));
                }

                $this.val(formatWithComma(value));

                if ($this.hasClass('order-kg')) {
                    let calculatedG = numValue * 1000;
                    $row.find('.order-g').val(formatWithComma(calculatedG.toFixed(4)));
                }
                else if ($this.hasClass('order-g')) {
                    let calculatedKg = numValue / 1000;
                    $row.find('.order-kg').val(formatWithComma(calculatedKg.toFixed(5)));
                }

                calculateRowPrice($row);
                recalculateAllQuantities();
            });

            $('#tempSaveBtn').on('click', function() {
                if (!confirm("현재 작성 중인 내용을 임시저장하시겠습니까?")) {
                    return;
                }

                let $form = $('#regForm');
                $form.find('input[inputmode="decimal"]').not(':disabled').each(function () {
                    let rawVal = $(this).val().replace(/,/g, '');
                    if(rawVal === '') rawVal = '0';
                    $(this).val(rawVal);
                });

                $form.attr('action', 'workOrderTempSaveAction.jsp');
                $form.submit();
            });

            $('#regForm').on('submit', function (e) {
                $(this).find('input[inputmode="decimal"]').not(':disabled').each(function () {
                    let rawVal = $(this).val().replace(/,/g, '');
                    if(rawVal === '') rawVal = '0';
                    $(this).val(rawVal);
                });
            });
        });
    </script>
<jsp:include page="/app/include/FooterDocType.jsp" />