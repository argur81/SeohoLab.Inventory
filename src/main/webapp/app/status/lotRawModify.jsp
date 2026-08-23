<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. PK 파라미터 수신 및 예외 처리 (item_lots 테이블의 lot_id 기준)
    String lotIdStr = request.getParameter("id");
    if (lotIdStr == null || lotIdStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='lotRawStatusList.jsp';</script>");
        return;
    }

    int lotId = 0;
    try {
        lotId = Integer.parseInt(lotIdStr);
    } catch (NumberFormatException e) {
        out.println("<script>alert('유효하지 않은 ID 형식입니다.'); location.href='lotRawStatusList.jsp';</script>");
        return;
    }

    // 2. DB 변수 선언
    int itemId = 0;
    String itemCode = "";
    String itemName = "";
    String lotNumber = "";
    String receiptDate = "";
    String manufactureDate = "";
    String expirationDate = "";
    int stockQtyT = 0;
    int stockQtyKg = 0;
    int stockQtyG = 0;
    int stockQtyMg = 0;

    // 3. DB 연결 및 데이터 조회 (item_lots와 items 테이블을 item_name으로 조인하여 item_id, item_code 함께 조회)
    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        String sql = "SELECT l.*, i.item_id, i.item_code FROM item_lots l LEFT JOIN items i ON l.item_name = i.item_name WHERE l.lot_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, lotId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            itemId = rs.getInt("item_id");
            itemCode = rs.getString("item_code") != null ? rs.getString("item_code") : "";
            itemName = rs.getString("item_name") != null ? rs.getString("item_name") : "";
            lotNumber = rs.getString("lot_number") != null ? rs.getString("lot_number") : "";
            receiptDate = rs.getString("receipt_date") != null ? rs.getString("receipt_date") : "";
            manufactureDate = rs.getString("manufacture_date") != null ? rs.getString("manufacture_date") : "";
            expirationDate = rs.getString("expiration_date") != null ? rs.getString("expiration_date") : "";
            stockQtyT = rs.getInt("stock_qty_t");
            stockQtyKg = rs.getInt("stock_qty_kg");
            stockQtyG = rs.getInt("stock_qty_g");
            stockQtyMg = rs.getInt("stock_qty_mg");
        } else {
            out.println("<script>alert('존재하지 않는 데이터입니다.'); location.href='lotRawStatusList.jsp';</script>");
            return;
        }
    } catch (Exception e) {
        out.println("<!-- DB Error: " + e.getMessage() + " -->");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content registPage">
                <div class="title_set">
                    <h5 class="page_tit"><p>품목관리</p><i><img src="/images/svg/location_arrow.svg"></i><b>Lot</b><i><img src="/images/svg/location_arrow.svg"></i>수정</h5>
                </div>
                <form id="modifyForm" action="lotRawModifyAction.jsp" method="post">
                    <input type="hidden" name="lotId" value="<%= lotId %>">
                    <input type="hidden" name="item_id" value="<%= itemId %>">
                    <section class="radius">
                        <dl class="w25">
                            <dt>품목 코드</dt>
                            <dd><input type="text" name="item_code" class="inputText" placeholder="품목 코드 입력" value="<%= itemCode %>" required disabled="disabled"></dd>
                        </dl>
                        <dl class="w50">
                            <dt>원료명</dt>
                            <dd><input type="text" name="item_name" class="inputText" placeholder="원료명 입력" value="<%= itemName %>" required></dd>
                        </dl>
                        <dl class="w25">
                            <dt>Lot 번호</dt>
                            <dd><input type="text" name="lot_number" class="inputText" placeholder="Lot 번호 입력" value="<%= lotNumber %>" required></dd>
                        </dl>
                        <dl class="w30">
                            <dt>입고일</dt>
                            <dd><input type="date" name="receipt_date" class="inputText" value="<%= receiptDate %>"></dd>
                        </dl>
                        <dl class="w30">
                            <dt>제조일</dt>
                            <dd><input type="date" name="manufacture_date" class="inputText" value="<%= manufactureDate %>"></dd>
                        </dl>
                        <dl class="w30">
                            <dt>EXP (만료일)</dt>
                            <dd><input type="date" name="expiration_date" class="inputText" value="<%= expirationDate %>"></dd>
                        </dl>
                        
                        <!-- 단위별 재고 개수 (톤, kg, g, mg) -->
                        <dl class="volume stock w100">
                            <dt>Lot 현재 재고</dt>
                            <dd>
                                <div class="unit_t"><input type="text" name="stock_qty_t" class="inputText" inputmode="decimal" value="<%= String.format("%,d", stockQtyT) %>"><i>t</i></div>
                                <div class="unit_kg"><input type="text" name="stock_qty_kg" class="inputText" inputmode="decimal" value="<%= String.format("%,d", stockQtyKg) %>"><i>kg</i></div>
                                <div class="unit_g"><input type="text" name="stock_qty_g" class="inputText" inputmode="decimal" value="<%= String.format("%,d", stockQtyG) %>"><i>g</i></div>
                                <div class="unit_mg"><input type="text" name="stock_qty_mg" class="inputText" inputmode="decimal" value="<%= String.format("%,d", stockQtyMg) %>"><i>mg</i></div>
                            </dd>
                        </dl>
                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="180" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="180">수정</button>
                            <button type="button" id="deleteBtn" class="Button brdrGray" data-width="180">삭제</button>
                        </div>
                    </section>
                </form>
            </div>
        </div>
        <script>
            $(document).ready(function () {
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

                $(document).on('input', 'input[inputmode="decimal"]:not([disabled])', function () {
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

                    $.each(unitToGram, function (unitClass, ratio) {
                        if (unitClass !== currentUnitClass) {
                            let calculated = baseGrams / ratio;
                            let calcStr = Number(calculated.toFixed(6)).toString();
                            let finalFormatted = formatWithComma(calcStr);
                            $parentGroup.find('.' + unitClass + ' input').val(finalFormatted);
                        }
                    });
                });

                $('#modifyForm').on('submit', function () {
                    const $parentGroup = $(this).find('dl.volume');

                    if ($userInput && $userInput.length > 0) {
                        $parentGroup.find('input[inputmode="decimal"]').not($userInput).val('');
                    }

                    $(this).find('input[inputmode="decimal"]').each(function () {
                        let rawVal = $(this).val().replace(/,/g, '');
                        $(this).val(rawVal);
                    });

                    $(this).find('input:disabled').removeAttr('disabled');
                });

                $('#deleteBtn').on('click', function () {
                    if (confirm('정말 삭제하시겠습니까?')) {
                        let form = $('#modifyForm');
                        form.attr('action', 'lotRawDeleteAction.jsp');
                        form.submit();
                    }
                });
            });
        </script>
    </div>
<jsp:include page="/app/include/FooterDocType.jsp" />