<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    String orderIdStr = request.getParameter("order_id");
    int orderId = 0;
    boolean isEditMode = false;

    if (orderIdStr != null && !orderIdStr.trim().isEmpty()) {
        try {
            orderId = Integer.parseInt(orderIdStr);
            if (orderId > 0) {
                isEditMode = true;
            }
        } catch (NumberFormatException e) {
            orderId = 0;
        }
    }

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String productName = "";
    double targetQty = 0;
    String targetUnit = "kg";
    String managerName = "";
    String machine = "";
    String appearance = "";
    String scent = "";
    String specificGravity = "";
    String ph = "";
    double theorQty = 0;
    String theorUnit = "kg";
    double yieldRate = 0;
    String yieldStandard = "";

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        if (isEditMode) {
            String sql = "SELECT * FROM work_orders WHERE order_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, orderId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                productName = rs.getString("product_name");
                targetQty = rs.getDouble("target_qty");
                targetUnit = rs.getString("target_unit");
                managerName = rs.getString("manager_name");
                machine = rs.getString("machine");
                appearance = rs.getString("appearance");
                scent = rs.getString("scent");
                specificGravity = rs.getString("specific_gravity");
                ph = rs.getString("ph");
                theorQty = rs.getDouble("theor_qty");
                theorUnit = rs.getString("theor_unit");
                yieldRate = rs.getDouble("yield_rate");
                yieldStandard = rs.getString("yield_standard");
            } else {
                out.println("<script>alert('해당 제조 지시서를 찾을 수 없습니다.'); history.back();</script>");
                return;
            }
            rs.close();
            pstmt.close();
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content workOrderList">
                <div class="title_set">
                    <h5 class="page_tit"><p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>관리·신규등록</b><i><img src="/images/svg/location_arrow.svg"></i><%= isEditMode ? "수정" : "등록" %></h5>
                </div>
                <form id="modifyForm" method="post" action="workOrderModifyAction.jsp">
                    <input type="hidden" name="order_id" value="<%= orderId %>">
                    <section class="radius">
                        <dl class="w50">
                            <dt>제품명</dt>
                            <dd><input type="text" name="product_name" class="inputText" value="<%= productName != null ? productName : "" %>" placeholder="제품명 입력" required></dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조지시량</dt>
                            <dd class="has_input-select">
                                <input type="text" name="target_qty" class="inputText top-target-qty" value="<%= targetQty > 0 ? targetQty : "" %>" inputmode="decimal">
                                <select name="target_unit" class="og_select top-target-unit">
                                    <option value="kg" <%= "kg".equals(targetUnit) ? "selected" : "" %>>kg</option>
                                    <option value="g" <%= "g".equals(targetUnit) ? "selected" : "" %>>g</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조지시자</dt>
                            <dd><input type="text" name="manager_name" class="inputText" value="<%= managerName != null ? managerName : "" %>"></dd>
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
                            <dd><input type="text" name="appearance" class="inputText" value="<%= appearance != null ? appearance : "" %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>향취</dt>
                            <dd><input type="text" name="scent" class="inputText" value="<%= scent != null ? scent : "" %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>비중</dt>
                            <dd><input type="text" name="specific_gravity" class="inputText" value="<%= specificGravity != null ? specificGravity : "" %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>pH</dt>
                            <dd><input type="text" name="ph" class="inputText" value="<%= ph != null ? ph : "" %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>이론제조량</dt>
                            <dd class="has_input-select">
                                <input type="text" name="theor_qty" class="inputText" value="<%= theorQty > 0 ? theorQty : "" %>" inputmode="decimal">
                                <select name="theor_unit" class="og_select">
                                    <option value="kg" <%= "kg".equals(theorUnit) ? "selected" : "" %>>kg</option>
                                    <option value="g" <%= "g".equals(theorUnit) ? "selected" : "" %>>g</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조수율</dt>
                            <dd><input type="text" name="yield_rate" class="inputText" value="<%= yieldRate > 0 ? yieldRate : "" %>" placeholder="제조수율 = (실제제조량/이론제조량) * 100"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>제조수율 기준</dt>
                            <dd><input type="text" name="yield_standard" class="inputText" value="<%= yieldStandard != null ? yieldStandard : "" %>"></dd>
                        </dl>
                    </section>
                    <section class="radius order">
                        <div class="top_btns">
                            <button type="button" id="updatePriceBtn" class="Button bgGray">현재 단가 적용</button>
                        </div>
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
    try {
        boolean hasItem = false;
        int rowIdx = 1;

        if (isEditMode) {
            String itemSql = "SELECT * FROM work_order_items WHERE order_id = ? ORDER BY item_row_id ASC";
            pstmt = conn.prepareStatement(itemSql);
            pstmt.setInt(1, orderId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                hasItem = true;
                String rawName = rs.getString("raw_material_name");
                String testNum = rs.getString("test_number");
                double contentPct = rs.getDouble("content_pct");
                double orderKg = rs.getDouble("order_qty_kg");
                double orderG = rs.getDouble("order_qty_g");
                double unitPrice = rs.getDouble("unit_price");
                long roundedPrice = Math.round(unitPrice);
                String formattedPrice = (roundedPrice > 0) ? String.format("%,d", roundedPrice) : "";
%>
                                <tr>
                                    <td data-roll="No">
                                        <span class="row-num"><%= rowIdx %></span>
                                        <% if (rowIdx > 1) { %>
                                        <button type="button" class="delRowBtn" title="삭제">삭제</button>
                                        <% } %>
                                    </td>
                                    <td data-roll="원료명"><input type="text" name="raw_material_name" class="inputText item-autocomplete" value="<%= rawName != null ? rawName : "" %>" placeholder="원료명 입력"></td>
                                    <td data-roll="원료시험번호"><input type="text" name="test_number" class="inputText" value="<%= testNum != null ? testNum : "" %>"></td>
                                    <td data-roll="함량(%)"><div class="unit"><input type="text" name="content_pct" class="inputText row-content-pct" value="<%= contentPct > 0 ? contentPct : "" %>" inputmode="decimal"><i>%</i></div></td>
                                    <td data-roll="제조지시량(kg)"><div class="unit"><input type="text" name="order_qty_kg" class="inputText order-kg" value="<%= orderKg > 0 ? orderKg : "" %>" inputmode="decimal"><i>kg</i></div></td>
                                    <td data-roll="제조지시량(g)"><div class="unit"><input type="text" name="order_qty_g" class="inputText order-g" value="<%= orderG > 0 ? orderG : "" %>" inputmode="decimal"><i>g</i></div></td>
                                    <td data-roll="단가"><div class="unit"><input type="text" name="unit_price" class="inputText item-price" value="<%= formattedPrice %>" inputmode="decimal"><i>원</i></div></td>
                                </tr>
<%
                rowIdx++;
            }
            rs.close();
            pstmt.close();
        }

        if (!hasItem) {
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
    } catch (Exception e) {
        e.printStackTrace();
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
<%
    try {
        boolean hasPhase = false;
        int pIdx = 0;

        if (isEditMode) {
            String phaseSql = "SELECT * FROM work_order_phases WHERE order_id = ? ORDER BY phase_row_id ASC";
            pstmt = conn.prepareStatement(phaseSql);
            pstmt.setInt(1, orderId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                hasPhase = true;
                String phaseTitle = rs.getString("phase_name");
                String phaseStart = rs.getString("phase_select_start");
                String phaseEnd = rs.getString("phase_select_end");
                String methodDesc = rs.getString("method_desc");
                String noteDesc = rs.getString("note_desc");
%>
                                <tr>
                                    <th>
                                        <span class="phase-name"><%= phaseTitle != null ? phaseTitle : "A상" %></span><input type="hidden" name="phase_title" value="<%= phaseTitle != null ? phaseTitle : "A상" %>" class="phase-title-input">
                                        <% if (pIdx > 0) { %>
                                        <button type="button" class="delPhaseBtn" title="삭제">삭제</button>
                                        <% } %>
                                    </th>
                                    <td data-roll="선택">
                                        <div class="phase_num">
                                            <select name="phase_start" class="og_select phase-start-sel" data-selected="<%= phaseStart != null ? phaseStart : "1" %>"></select>
                                            <i>~</i>
                                            <select name="phase_end" class="og_select phase-end-sel" data-selected="<%= phaseEnd != null ? phaseEnd : "1" %>"></select>
                                        </div>
                                    </td>
                                    <td data-roll="제조방법">
                                        <textarea name="method_desc" class="textArea" placeholder="제조방법 입력"><%= methodDesc != null ? methodDesc : "" %></textarea>
                                    </td>
                                    <td data-roll="비고">
                                        <textarea name="note_desc" class="textArea" placeholder="비고 입력"><%= noteDesc != null ? noteDesc : "" %></textarea>
                                    </td>
                                </tr>
<%
                pIdx++;
            }
            rs.close();
            pstmt.close();
        }

        if (!hasPhase) {
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
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>
                            </tbody>
                        </table>
                        <div class="add_btn">
                            <button type="button" id="addPhaseBtn" class="Button">추가</button>
                        </div>
                    </section>
                    <div class="bottom_btns">
                        <button type="button" class="Button bgGray" data-width="180" onclick="location.href='workOrderMgmtList.jsp';">목록</button>
                        <button type="button" class="Button brdrYellow" data-width="180" id="tempSaveBtn">임시저장</button>
                        
                        <button type="submit" class="Button bgBlue" data-width="180"><%= isEditMode ? "수정" : "등록" %></button>
                        
                        <% if (isEditMode) { %>
                        <button type="button" class="Button brdrGreen" data-width="180" id="saveAsNewBtn">새 이름으로 저장</button>
                        <% } %>

                        <% if (isEditMode) { %>
                        <button type="button" class="Button brdrGray" data-width="180" id="deleteBtn">삭제</button>
                        <% } %>
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
                return val * 1000;
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
            } else {
                let rowKg = topTargetKg * (pct / 100);
                calculatedPrice = basePrice * rowKg;
            }

            $row.find('.item-price').val(formatWithComma(Math.round(calculatedPrice)));
        }

        function recalculateAllQuantities() {
            let topTargetGrams = getTopTargetGrams();
            let $rows = $(".order_table tbody tr");
            let totalRows = $rows.length;

            let accumulatedG = 0;
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
                    if (index === totalRows - 1) {
                        rowGrams = Math.round((topTargetGrams - accumulatedG) * 10000) / 10000;
                        if (rowGrams < 0) rowGrams = 0;
                    } else {
                        rowGrams = (topTargetGrams * pct) / 100;
                        accumulatedG += rowGrams;
                        rowGrams = Math.round(rowGrams * 10000) / 10000; 
                    }
                }

                let rowKg = rowGrams / 1000;

                if (pct > 0 || rowGrams > 0) {
                    $row.find('.order-g').val(rowGrams > 0 ? formatWithComma(rowGrams) : "");
                    $row.find('.order-kg').val(rowKg > 0 ? rowKg : "");
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
            $(".order_table tfoot .total-kg").val(formatWithComma(Math.round(totalKg)));
            $(".order_table tfoot .total-g").val(formatWithComma(Math.round(totalG * 10000) / 10000));
            $(".order_table tfoot .total-price").val(formatWithComma(Math.round(totalPrice)));
        }

        $(document).ready(function () {
            function initAutocomplete($elem) {
                $elem.autocomplete({
                    source: "getItemAutoComplete.jsp",
                    minLength: 1,
                    select: function (event, ui) {
                        let $row = $(this).closest('tr');
                        let roundedBasePrice = Math.round(ui.item.price || 0);
                        
                        $row.find('.item-price').data('price-type', ui.item.priceType);
                        $row.find('.item-price').data('base-price', roundedBasePrice);
                        
                        calculateRowPrice($row);
                        recalculateAllQuantities();
                    }
                });
            }

            $("#updatePriceBtn").on("click", function() {
                let $rows = $(".order_table tbody tr");
                let totalRows = $rows.length;
                let checkedCount = 0;
                let hasChanged = false;

                if (totalRows === 0) return;

                $rows.each(function() {
                    let $row = $(this);
                    let rawName = $row.find('.item-autocomplete').val();
                    
                    if (!rawName) {
                        checkedCount++;
                        if (checkedCount === totalRows) {
                            recalculateAllQuantities();
                            checkAndAlert(hasChanged);
                        }
                        return;
                    }

                    let $priceInput = $row.find('.item-price');
                    let currentUIPrice = parseFloat($priceInput.val().replace(/,/g, '')) || 0;

                    $.ajax({
                        url: "getItemAutoComplete.jsp",
                        type: "GET",
                        data: { term: rawName },
                        dataType: "json",
                        success: function(data) {
                            let foundItem = null;
                            if (data && data.length > 0) {
                                for (let i = 0; i < data.length; i++) {
                                    if (data[i].label === rawName || data[i].value === rawName) {
                                        foundItem = data[i];
                                        break;
                                    }
                                }
                                if (!foundItem) foundItem = data[0];
                            }

                            if (foundItem && foundItem.price) {
                                let newDbPrice = Math.round(parseFloat(foundItem.price) || 0);

                                if (currentUIPrice !== newDbPrice) {
                                    hasChanged = true;
                                }

                                $priceInput.data('price-type', foundItem.priceType);
                                $priceInput.data('base-price', newDbPrice);
                                calculateRowPrice($row);
                            }
                        },
                        complete: function() {
                            checkedCount++;
                            if (checkedCount === totalRows) {
                                recalculateAllQuantities();
                                checkAndAlert(hasChanged);
                            }
                        }
                    });
                });

                function checkAndAlert(changed) {
                    if (changed) {
                        alert("현재 단가가 적용되었습니다.");
                    } else {
                        alert("현재 원료에 변동 된 단가가 없습니다.");
                    }
                }
            });

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

                    let savedStart = parseInt($startSel.attr("data-selected")) || (previousEnd + 1);
                    let savedEnd = parseInt($endSel.attr("data-selected")) || totalRows;

                    let currentStartVal = parseInt($startSel.val()) || savedStart;
                    let currentEndVal = parseInt($endSel.val()) || savedEnd;

                    $startSel.removeAttr("data-selected");
                    $endSel.removeAttr("data-selected");

                    if (currentStartVal > totalRows) currentStartVal = totalRows;
                    if (currentEndVal > totalRows) currentEndVal = totalRows;
                    if (currentEndVal < currentStartVal) currentEndVal = currentStartVal;

                    if (index > 0 && currentStartVal <= previousEnd) {
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

            $(".order_table tbody tr").each(function () {
                let $row = $(this);
                let $priceInput = $row.find('.item-price');
                let existingPrice = parseFloat($priceInput.val().replace(/,/g, '')) || 0;
                let topTargetKg = getTopTargetGrams() / 1000;
                let pct = parseFloat($row.find('.row-content-pct').val().replace(/,/g, '')) || 0;

                if (existingPrice > 0 && topTargetKg > 0 && pct > 0) {
                    let calculatedKg = topTargetKg * (pct / 100);
                    if (calculatedKg > 0) {
                        let basePricePerKg = existingPrice / calculatedKg;
                        $priceInput.data('base-price', basePricePerKg);
                        $priceInput.data('price-type', '1kg기준');
                    }
                }
            });

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
                $(".order_table tbody tr").each(function () {
                    calculateRowPrice($(this));
                });
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
                calculateRowPrice($row);
                recalculateAllQuantities();
            });

            // [임시저장] 버튼 클릭 이벤트
            $("#tempSaveBtn").on("click", function() {
                if (confirm("현재 작성 중인 내용을 임시저장하시겠습니까?")) {
                    let $form = $('#modifyForm');
                    $form.find('input[inputmode="decimal"]').not(':disabled').each(function () {
                        let rawVal = $(this).val().replace(/,/g, '');
                        if(rawVal === '') rawVal = '0';
                        $(this).val(rawVal);
                    });
                    $form.attr('action', 'workOrderTempSaveAction.jsp');
                    $form.submit();
                }
            });

            // [추가됨] [새 이름으로 저장] 버튼 클릭 이벤트
            $("#saveAsNewBtn").on("click", function() {
                if (confirm("현재 내용을 새 제조 지시서로 신규 등록하시겠습니까?")) {
                    let $form = $('#modifyForm');
                    
                    // 입력 필드 콤마 제거
                    $form.find('input[inputmode="decimal"]').not(':disabled').each(function () {
                        let rawVal = $(this).val().replace(/,/g, '');
                        if(rawVal === '') rawVal = '0';
                        $(this).val(rawVal);
                    });

                    // order_id를 0으로 만들어 신규 등록(INSERT)을 유도
                    $form.find('input[name="order_id"]').val("0"); 
                    
                    // 등록 처리 액션 파일(workOrderRegistAction.jsp)로 action 변경
                    $form.attr('action', 'workOrderRegistAction.jsp'); 
                    $form.submit();
                }
            });

            <% if (isEditMode) { %>
            $("#deleteBtn").on("click", function() {
                if (confirm("정말 이 제조 지시서를 삭제하시겠습니까?")) {
                    location.href = "workOrderDeleteAction.jsp?order_id=<%= orderId %>";
                }
            });
            <% } %>

            $('#modifyForm').on('submit', function (e) {
                let activeBtnId = $(document.activeElement).attr('id');
                if (activeBtnId === 'tempSaveBtn' || activeBtnId === 'saveAsNewBtn') return;
                
                $(this).find('input[inputmode="decimal"]').not(':disabled').each(function () {
                    let rawVal = $(this).val().replace(/,/g, '');
                    if(rawVal === '') rawVal = '0';
                    $(this).val(rawVal);
                });
            });
        });
    </script>
<jsp:include page="/app/include/FooterDocType.jsp" />