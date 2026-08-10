<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. PK 파라미터 수신 및 예외 처리
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

    // 2. DB 데이터를 담을 변수 선언 및 초기화
    String category = "";
    String itemName = "";
    String workOrder1 = "", workOrder2 = "", workOrder3 = "";
    String lotNumber = "";
    String receiptDate = "", manufactureDate = "", expirationDate = "";

    // DB 수치
    double stockQtyT = 0, stockQtyKg = 0, stockQtyG = 0, stockQtyMg = 0;
    double minQtyT = 0, minQtyKg = 0, minQtyG = 0, minQtyMg = 0;

    // 3. Cloudtype MariaDB 접속 설정
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

        String sql = "SELECT * FROM items WHERE item_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, itemId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            category = rs.getString("category") != null ? rs.getString("category") : "RAW";
            itemName = rs.getString("item_name") != null ? rs.getString("item_name") : "";
            
            workOrder1 = rs.getString("work_order_1") != null ? rs.getString("work_order_1") : "";
            workOrder2 = rs.getString("work_order_2") != null ? rs.getString("work_order_2") : "";
            workOrder3 = rs.getString("work_order_3") != null ? rs.getString("work_order_3") : "";
            
            // 현재 재고 수량
            stockQtyT = rs.getDouble("stock_qty_t");
            stockQtyKg = rs.getDouble("stock_qty_kg");
            stockQtyG = rs.getDouble("stock_qty_g");
            stockQtyMg = rs.getDouble("stock_qty_mg");

            // 최소 재고 수량
            minQtyT = rs.getDouble("min_qty_t");
            minQtyKg = rs.getDouble("min_qty_kg");
            minQtyG = rs.getDouble("min_qty_g");
            minQtyMg = rs.getDouble("min_qty_mg");
        } else {
            out.println("<script>alert('존재하지 않는 데이터입니다.'); location.href='rawMaterialStockList.jsp';</script>");
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

    // 숫자를 콤마 포맷팅용 문자열로 변환하는 포맷터
    DecimalFormat df = new DecimalFormat("#,##0.######");
%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content registPage">
                <div class="title_set">
                    <h5 class="page_tit"><p>원료</p><i><img src="/images/svg/location_arrow.svg"></i><b>재고현황</b><i><img src="/images/svg/location_arrow.svg"></i>수정</h5>
                </div>
                <form action="rawMaterialModifyAction.jsp" method="post">
                    <input type="hidden" name="itemId" value="<%= itemId %>">
                    <input type="hidden" name="category" value="<%= category %>">
                    
                    <!-- 현재 재고는 수정 불가하므로 hidden으로 서버 전송 -->
                    <input type="hidden" name="stock_qty_t" value="<%= stockQtyT %>">
                    <input type="hidden" name="stock_qty_kg" value="<%= stockQtyKg %>">
                    <input type="hidden" name="stock_qty_g" value="<%= stockQtyG %>">
                    <input type="hidden" name="stock_qty_mg" value="<%= stockQtyMg %>">

                    <section class="radius">
                        <dl class="w25">
                            <dt>원료명</dt>
                            <dd><input type="text" name="item_name" class="inputText" placeholder="원료명 입력" value="<%= itemName %>" required></dd>
                        </dl>
                        <dl class="w25">
                            <dt>작업 지시서명1</dt>
                            <dd><input type="text" name="work_order_1" class="inputText" placeholder="작업 지시서명1 입력" value="<%= workOrder1 %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>작업 지시서명2</dt>
                            <dd><input type="text" name="work_order_2" class="inputText" placeholder="작업 지시서명2 입력" value="<%= workOrder2 %>"></dd>
                        </dl>
                        <dl class="w25">
                            <dt>작업 지시서명3</dt>
                            <dd><input type="text" name="work_order_3" class="inputText" placeholder="작업 지시서명3 입력" value="<%= workOrder3 %>"></dd>
                        </dl>

                        <!-- 현재 재고물량 (disabled input에서는 name 속성 제거하여 파라미터 충돌 방지) -->
                        <dl class="volume stock">
                            <dt>현재 재고물량</dt>
                            <dd>
                                <div class="unit_t"><input type="text" class="inputText" inputmode="decimal" value="<%= df.format(stockQtyT) %>" disabled="disabled"><i>t</i></div>
                                <div class="unit_kg"><input type="text" class="inputText" inputmode="decimal" value="<%= df.format(stockQtyKg) %>" disabled="disabled"><i>kg</i></div>
                                <div class="unit_g"><input type="text" class="inputText" inputmode="decimal" value="<%= df.format(stockQtyG) %>" disabled="disabled"><i>g</i></div>
                                <div class="unit_mg"><input type="text" class="inputText" inputmode="decimal" value="<%= df.format(stockQtyMg) %>" disabled="disabled"><i>mg</i></div>
                            </dd>
                        </dl>

                        <!-- 최소 재고물량 (수정 가능) -->
                        <dl class="volume min">
                            <dt>최소 재고물량</dt>
                            <dd>
                                <div class="unit_t"><input type="text" name="min_qty_t" class="inputText" inputmode="decimal" value="<%= df.format(minQtyT) %>"><i>t</i></div>
                                <div class="unit_kg"><input type="text" name="min_qty_kg" class="inputText" inputmode="decimal" value="<%= df.format(minQtyKg) %>"><i>kg</i></div>
                                <div class="unit_g"><input type="text" name="min_qty_g" class="inputText" inputmode="decimal" value="<%= df.format(minQtyG) %>"><i>g</i></div>
                                <div class="unit_mg"><input type="text" name="min_qty_mg" class="inputText" inputmode="decimal" value="<%= df.format(minQtyMg) %>"><i>mg</i></div>
                            </dd>
                        </dl>

                        <div class="bottom_btns">
                            <button type="button" class="Button bgGray" data-width="100" onclick="history.back();">취소</button>
                            <button type="submit" class="Button bgBlue" data-width="100">수정</button>
                        </div>
                    </section>
                </form>
            </div>
        </div>

        <script>
            $(document).ready(function() {
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

                // 최소 재고물량 입력 시 단위 자동 계산 및 포맷팅
                $(document).on('input', 'dl.min input[inputmode="decimal"]', function() {
                    let $this = $(this);
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

                // Form submit 시 콤마 제거 후 전송
                $('form').on('submit', function () {
                    $(this).find('input[inputmode="decimal"]').not(':disabled').each(function () {
                        let rawVal = $(this).val().replace(/,/g, '');
                        $(this).val(rawVal);
                    });
                });
            });
        </script>
    </div>
<jsp:include page="/app/include/FooterDocType.jsp" />