<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
    response.setCharacterEncoding("UTF-8");

    String itemIdStr = request.getParameter("id");
    if (itemIdStr == null || itemIdStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='rawMaterialStockList.jsp';</script>");
        return;
    }

    int itemId = 0;
    try {
        itemId = Integer.parseInt(itemIdStr);
    } catch (NumberFormatException e) {
        out.println("<script>alert('유효하지 않은 ID 형식입니다.'); location.href='rawMaterialStockList.jsp';</script>");
        return;
    }

    // 변수 선언
    String category = "", itemCode = "", itemName = "";
    String workOrder1 = "", workOrder2 = "";
    String chemName = "", inciName = "", casNo = "", supplier = "", maker = "";
    
    // 단가 관련 변수
    String priceType = "";
    double price = 0;
    double kgQty1 = 0, kgPrice1 = 0, kgQty2 = 0, kgPrice2 = 0, kgQty3 = 0, kgPrice3 = 0, kgQty4 = 0, kgPrice4 = 0;
    String kgUnit1 = "kg", kgUnit2 = "kg", kgUnit3 = "kg", kgUnit4 = "kg";
    String priceEtc = "";

    // Packing 단위
    String packingUnit = "";
    String packingUnitSelect = "kg";

    // 기타 항목
    String func = "", rHlb = "", hlb = "", certification = "", extraInfo = "", labName = "", origin = "", note = "";

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        String sql = "SELECT * FROM items WHERE item_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, itemId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            category = rs.getString("category") != null ? rs.getString("category") : "RAW";
            itemCode = rs.getString("item_code") != null ? rs.getString("item_code") : "";
            itemName = rs.getString("item_name") != null ? rs.getString("item_name") : "";
            
            workOrder1 = rs.getString("work_order_1") != null ? rs.getString("work_order_1") : "";
            workOrder2 = rs.getString("work_order_2") != null ? rs.getString("work_order_2") : "";
            
            chemName = rs.getString("chem_name") != null ? rs.getString("chem_name") : "";
            inciName = rs.getString("inci_name") != null ? rs.getString("inci_name") : "";
            casNo = rs.getString("cas_no") != null ? rs.getString("cas_no") : "";
            supplier = rs.getString("supplier") != null ? rs.getString("supplier") : "";
            maker = rs.getString("maker") != null ? rs.getString("maker") : "";
            
            priceType = rs.getString("price_type") != null ? rs.getString("price_type") : "1kg기준";
            price = rs.getDouble("price");

            kgQty1 = rs.getDouble("kg_qty_1"); kgUnit1 = rs.getString("kg_unit_1") != null ? rs.getString("kg_unit_1") : "kg"; kgPrice1 = rs.getDouble("kg_price_1");
            kgQty2 = rs.getDouble("kg_qty_2"); kgUnit2 = rs.getString("kg_unit_2") != null ? rs.getString("kg_unit_2") : "kg"; kgPrice2 = rs.getDouble("kg_price_2");
            kgQty3 = rs.getDouble("kg_qty_3"); kgUnit3 = rs.getString("kg_unit_3") != null ? rs.getString("kg_unit_3") : "kg"; kgPrice3 = rs.getDouble("kg_price_3");
            kgQty4 = rs.getDouble("kg_qty_4"); kgUnit4 = rs.getString("kg_unit_4") != null ? rs.getString("kg_unit_4") : "kg"; kgPrice4 = rs.getDouble("kg_price_4");

            priceEtc = rs.getString("price_etc") != null ? rs.getString("price_etc") : "";

            packingUnit = rs.getString("packing_unit") != null ? rs.getString("packing_unit") : "";
            packingUnitSelect = rs.getString("packing_unit_select") != null ? rs.getString("packing_unit_select") : "kg";

            func = rs.getString("func") != null ? rs.getString("func") : "";
            rHlb = rs.getString("r_hlb") != null ? rs.getString("r_hlb") : "";
            hlb = rs.getString("hlb") != null ? rs.getString("hlb") : "";
            certification = rs.getString("certification") != null ? rs.getString("certification") : "";
            extraInfo = rs.getString("extra_info") != null ? rs.getString("extra_info") : "";
            labName = rs.getString("lab_name") != null ? rs.getString("lab_name") : "";
            origin = rs.getString("origin") != null ? rs.getString("origin") : "";
            note = rs.getString("note") != null ? rs.getString("note") : "";
        } else {
            out.println("<script>alert('존재하지 않는 데이터입니다.'); location.href='rawMaterialStockList.jsp';</script>");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }

    DecimalFormat df = new DecimalFormat("#,##0.######");
%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content registPage">
                <div class="title_set">
                    <h5 class="page_tit"><p>품목관리</p><i><img src="/images/svg/location_arrow.svg"></i><b>원료</b><i><img src="/images/svg/location_arrow.svg"></i>수정</h5>
                </div>
                <form action="rawStatusModifyAction.jsp" method="post" id="modifyForm">
                    <input type="hidden" name="itemId" value="<%= itemId %>">
                    <input type="hidden" name="category" value="<%= category %>">

                    <section class="radius">
                        <dl class="w25">
                            <dt>원료코드</dt>
                            <dd><input type="text" name="item_code" class="inputText" value="<%= itemCode %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>상품명 (Trade Name)</dt>
                            <dd><input type="text" name="item_name" class="inputText" value="<%= itemName %>" required></dd>
                        </dl>
                        <dl class="w25">
                            <dt>작업 지시서명1</dt>
                            <dd><input type="text" name="work_order_1" class="inputText" value="<%= workOrder1 %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>작업 지시서명2</dt>
                            <dd><input type="text" name="work_order_2" class="inputText" value="<%= workOrder2 %>"></dd>
                        </dl>
                        
                        <dl class="w25">
                            <dt>화학명(한글)</dt>
                            <dd>
                                <textarea class="textArea input_size" name="chem_name" placeholder="화학명(한글) 입력"><%= chemName %></textarea>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>INCI Name</dt>
                            <dd><input type="text" name="inci_name" class="inputText" value="<%= inciName %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>CAS No.</dt>
                            <dd><input type="text" name="cas_no" class="inputText" value="<%= casNo %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>공급업체</dt>
                            <dd><input type="text" name="supplier" class="inputText" value="<%= supplier %>"></dd>
                        </dl>

                        <dl class="w25">
                            <dt>제조사</dt>
                            <dd><input type="text" name="maker" class="inputText" value="<%= maker %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>단가구분</dt>
                            <dd>
                                <select name="price_type" id="priceTypeSelect" class="og_select">
                                    <option value="1kg기준" <%= "1kg기준".equals(priceType) ? "selected" : "" %>>1kg기준</option>
                                    <option value="1g기준" <%= "1g기준".equals(priceType) ? "selected" : "" %>>1g기준</option>
                                    <option value="무게별" <%= "무게별".equals(priceType) ? "selected" : "" %>>무게별</option>
                                    <option value="기타" <%= "기타".equals(priceType) ? "selected" : "" %>>기타</option>
                                </select>
                            </dd>
                        </dl>

                        <!-- 단가 항목 -->
                        <dl class="w25" id="priceDl">
                            <dt>단가</dt>
                            <dd>
                                <div class="price_div direct" style="display:none;">
                                    <input type="text" name="price" id="priceInput" class="inputText" value="<%= df.format(price) %>" placeholder="숫자 단가 입력" inputmode="decimal">
                                </div>
                                <div class="price_div kg_enter" style="display:none;">
                                    <ul>
                                        <li>
                                            <p>
                                                <input type="text" name="kg_qty_1" class="inputText" value="<%= df.format(kgQty1) %>" placeholder="숫자 입력" inputmode="decimal">
                                                <select name="kg_unit_1" class="og_select">
                                                    <option <%= "t".equals(kgUnit1) ? "selected" : "" %>>t</option>
                                                    <option <%= "kg".equals(kgUnit1) ? "selected" : "" %>>kg</option>
                                                    <option <%= "g".equals(kgUnit1) ? "selected" : "" %>>g</option>
                                                    <option <%= "mg".equals(kgUnit1) ? "selected" : "" %>>mg</option>
                                                </select>
                                            </p>
                                            <div><input type="text" name="kg_price_1" class="inputText" value="<%= df.format(kgPrice1) %>" placeholder="숫자 입력" inputmode="decimal"></div>
                                        </li>
                                        <li>
                                            <p>
                                                <input type="text" name="kg_qty_2" class="inputText" value="<%= df.format(kgQty2) %>" placeholder="숫자 입력" inputmode="decimal">
                                                <select name="kg_unit_2" class="og_select">
                                                    <option <%= "t".equals(kgUnit2) ? "selected" : "" %>>t</option>
                                                    <option <%= "kg".equals(kgUnit2) ? "selected" : "" %>>kg</option>
                                                    <option <%= "g".equals(kgUnit2) ? "selected" : "" %>>g</option>
                                                    <option <%= "mg".equals(kgUnit2) ? "selected" : "" %>>mg</option>
                                                </select>
                                            </p>
                                            <div><input type="text" name="kg_price_2" class="inputText" value="<%= df.format(kgPrice2) %>" placeholder="숫자 입력" inputmode="decimal"></div>
                                        </li>
                                        <li>
                                            <p>
                                                <input type="text" name="kg_qty_3" class="inputText" value="<%= df.format(kgQty3) %>" placeholder="숫자 입력" inputmode="decimal">
                                                <select name="kg_unit_3" class="og_select">
                                                    <option <%= "t".equals(kgUnit3) ? "selected" : "" %>>t</option>
                                                    <option <%= "kg".equals(kgUnit3) ? "selected" : "" %>>kg</option>
                                                    <option <%= "g".equals(kgUnit3) ? "selected" : "" %>>g</option>
                                                    <option <%= "mg".equals(kgUnit3) ? "selected" : "" %>>mg</option>
                                                </select>
                                            </p>
                                            <div><input type="text" name="kg_price_3" class="inputText" value="<%= df.format(kgPrice3) %>" placeholder="숫자 입력" inputmode="decimal"></div>
                                        </li>
                                        <li>
                                            <p>
                                                <input type="text" name="kg_qty_4" class="inputText" value="<%= df.format(kgQty4) %>" placeholder="숫자 입력" inputmode="decimal">
                                                <select name="kg_unit_4" class="og_select">
                                                    <option <%= "t".equals(kgUnit4) ? "selected" : "" %>>t</option>
                                                    <option <%= "kg".equals(kgUnit4) ? "selected" : "" %>>kg</option>
                                                    <option <%= "g".equals(kgUnit4) ? "selected" : "" %>>g</option>
                                                    <option <%= "mg".equals(kgUnit4) ? "selected" : "" %>>mg</option>
                                                </select>
                                            </p>
                                            <div><input type="text" name="kg_price_4" class="inputText" value="<%= df.format(kgPrice4) %>" placeholder="숫자 입력" inputmode="decimal"></div>
                                        </li>
                                    </ul>
                                </div>
                                <div class="price_div etc_price" style="display:none;">
                                    <input type="text" name="price_etc" class="inputText" value="<%= priceEtc %>" placeholder="(예: 인상이슈, 가격인상 등)">
                                </div>
                            </dd>
                        </dl>
                        <dl class="w100">
                            <dt>원료추가정보</dt>
                            <dd>
                                <textarea class="textArea input_size" name="extra_info" placeholder="원료추가정보 입력"><%= extraInfo %></textarea>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>Function</dt>
                            <dd>
                                <textarea class="textArea input_size" name="func" placeholder="Function 입력"><%= func %></textarea>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>Packing 단위</dt>
                            <dd class="has_input-select">
                                <input type="text" name="packing_unit" class="inputText" value="<%= packingUnit %>">
                                <select name="packing_unit_select" class="og_select">
                                    <option <%= "t".equals(packingUnitSelect) ? "selected" : "" %>>t</option>
                                    <option <%= "kg".equals(packingUnitSelect) ? "selected" : "" %>>kg</option>
                                    <option <%= "g".equals(packingUnitSelect) ? "selected" : "" %>>g</option>
                                    <option <%= "mg".equals(packingUnitSelect) ? "selected" : "" %>>mg</option>
                                    <option <%= "Drum".equals(packingUnitSelect) ? "selected" : "" %>>Drum</option>
                                    <option <%= "ℓ".equals(packingUnitSelect) ? "selected" : "" %>>ℓ</option>
                                    <option <%= "기타".equals(packingUnitSelect) ? "selected" : "" %>>기타</option>
                                </select>
                            </dd>
                        </dl>
                        <dl class="w25">
                            <dt>rHLB</dt>
                            <dd><input type="text" name="r_hlb" class="inputText" value="<%= rHlb %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>HLB</dt>
                            <dd><input type="text" name="hlb" class="inputText" value="<%= hlb %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>인증</dt>
                            <dd><input type="text" name="certification" class="inputText" value="<%= certification %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>유래</dt>
                            <dd><textarea name="origin" class="textArea input_size"><%= origin %></textarea></dd>
                        </dl>
                        <dl class="w25">
                            <dt>특이사항</dt>
                            <dd><textarea name="note" class="textArea input_size"><%= note %></textarea></dd>
                        </dl>
                        <dl class="w25">
                            <dt>연구실명칭</dt>
                            <dd><input type="text" name="lab_name" class="inputText" value="<%= labName %>"></dd>
                        </dl>

                        <!-- 하단 버튼 영역 -->
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="180" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="180">수정</button>
                            <button type="button" class="Button brdrGray" data-width="180" onclick="deleteItem(<%= itemId %>);">삭제</button>
                        </div>
                    </section>
                </form>
            </div>
        </div>

        <script>
            function deleteItem(itemId) {
                if (confirm('정말 이 원료 정보를 삭제하시겠습니까?')) {
                    const form = document.createElement('form');
                    form.method = 'post';
                    form.action = 'rawStatusDeleteAction.jsp';
                    
                    const input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = 'itemId';
                    input.value = itemId;
                    
                    form.appendChild(input);
                    document.body.appendChild(form);
                    form.submit();
                }
            }

            $(document).ready(function() {
                function formatWithComma(str) {
                    if (!str) return '';
                    const parts = str.split('.');
                    parts[0] = parts[0].replace(/,/g, '').replace(/\B(?=(\d{3})+(?!\d))/g, ',');
                    return parts.join('.');
                }

                $('#priceTypeSelect').on('change', function() {
                    let selectedVal = $(this).val();
                    let $priceDl = $('#priceDl');

                    $priceDl.find('.price_div').hide();
                    $priceDl.find('input').prop('disabled', true);

                    if (selectedVal === '1kg기준' || selectedVal === '1g기준') {
                        $priceDl.removeClass('w100').addClass('w25');
                        let $target = $priceDl.find('.direct');
                        $target.show();
                        $target.find('input').prop('disabled', false);

                        if (selectedVal === '1kg기준') {
                            $target.find('input').attr('placeholder', '1kg당 단가 입력');
                        } else {
                            $target.find('input').attr('placeholder', '1g당 단가 입력');
                        }
                    } else if (selectedVal === '무게별') {
                        $priceDl.removeClass('w25').addClass('w100');
                        let $target = $priceDl.find('.kg_enter');
                        $target.show();
                        $target.find('input').prop('disabled', false);
                    } else if (selectedVal === '기타') {
                        $priceDl.removeClass('w100').addClass('w25');
                        let $target = $priceDl.find('.etc_price');
                        $target.show();
                        $target.find('input').prop('disabled', false);
                    }
                });

                $('#priceTypeSelect').trigger('change');

                $(document).on('input', 'input[inputmode="decimal"]', function() {
                    let $this = $(this);
                    if ($this.is(':disabled')) return;

                    let value = $this.val().replace(/[^0-9.]/g, '');
                    const parts = value.split('.');
                    if (parts.length > 2) value = parts[0] + '.' + parts.slice(1).join('');

                    $this.val(formatWithComma(value));
                });

                $('#modifyForm').on('submit', function () {
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