<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    request.setCharacterEncoding("UTF-8");

    String itemIdStr = request.getParameter("id");
    if (itemIdStr == null || itemIdStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='rawMaterialStockList.jsp';</script>");
        return;
    }

    int itemId = Integer.parseInt(itemIdStr);
    
    // 남길 항목 변수
    String category = "", itemCode = "", itemName = "", workOrder1 = "", workOrder2 = "";
    double stockQtyT = 0, stockQtyKg = 0, stockQtyG = 0, stockQtyMg = 0;
    double minQtyT = 0, minQtyKg = 0, minQtyG = 0, minQtyMg = 0;

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
            category = rs.getString("category");
            itemCode = rs.getString("item_code");
            itemName = rs.getString("item_name");
            workOrder1 = rs.getString("work_order_1");
            workOrder2 = rs.getString("work_order_2");
            stockQtyT = rs.getDouble("stock_qty_t");
            stockQtyKg = rs.getDouble("stock_qty_kg");
            stockQtyG = rs.getDouble("stock_qty_g");
            stockQtyMg = rs.getDouble("stock_qty_mg");
            minQtyT = rs.getDouble("min_qty_t");
            minQtyKg = rs.getDouble("min_qty_kg");
            minQtyG = rs.getDouble("min_qty_g");
            minQtyMg = rs.getDouble("min_qty_mg");
        }
    } catch (Exception e) { e.printStackTrace(); } finally { if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close(); if(conn!=null) conn.close(); }
    DecimalFormat df = new DecimalFormat("#,##0.######");
%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
<div id="wrap">
    <jsp:include page="/app/include/Header.jsp" />
    <div id="container">
        <div class="content registPage">
            <div class="title_set">
                <h5 class="page_tit"><p>재고현황</p><i><img src="/images/svg/location_arrow.svg"></i><b>원료</b><i><img src="/images/svg/location_arrow.svg"></i>수정</h5>
            </div>
            <form action="rawMaterialModifyAction.jsp" method="post">
                <input type="hidden" name="itemId" value="<%= itemId %>">
                <input type="hidden" name="category" value="<%= category %>">
                <input type="hidden" name="item_code" value="<%= itemCode %>">
                <input type="hidden" name="item_name" value="<%= itemName %>">
                <input type="hidden" name="stock_qty_t" value="<%= stockQtyT %>">
                <input type="hidden" name="stock_qty_kg" value="<%= stockQtyKg %>">
                <input type="hidden" name="stock_qty_g" value="<%= stockQtyG %>">
                <input type="hidden" name="stock_qty_mg" value="<%= stockQtyMg %>">

                <section class="radius">
                    <dl class="w25"><dt>원료코드</dt><dd><input type="text" name="item_code" class="inputText" value="<%= itemCode %>" disabled="disabled"></dd></dl>
                    <dl class="w25"><dt>상품명 (Trade Name)</dt><dd><input type="text" name="item_name" class="inputText" value="<%= itemName %>" required disabled="disabled"></dd></dl>
                    <dl class="w25"><dt>작업 지시서명1</dt><dd><input type="text" name="work_order_1" class="inputText" value="<%= workOrder1 %>"></dd></dl>
                    <dl class="w25"><dt>작업 지시서명2</dt><dd><input type="text" name="work_order_2" class="inputText" value="<%= workOrder2 %>"></dd></dl>
                    
                    <dl class="volume stock"><dt>현재 재고물량</dt><dd>
                        <div class="unit_t"><input type="text" class="inputText" value="<%= df.format(stockQtyT) %>" disabled="disabled"><i>t</i></div>
                        <div class="unit_kg"><input type="text" class="inputText" value="<%= df.format(stockQtyKg) %>" disabled="disabled"><i>kg</i></div>
                        <div class="unit_g"><input type="text" class="inputText" value="<%= df.format(stockQtyG) %>" disabled="disabled"><i>g</i></div>
                        <div class="unit_mg"><input type="text" class="inputText" value="<%= df.format(stockQtyMg) %>" disabled="disabled"><i>mg</i></div>
                    </dd></dl>

                    <dl class="volume min"><dt>최소 재고물량</dt><dd>
                        <div class="unit_t"><input type="text" name="min_qty_t" class="inputText" inputmode="decimal" value="<%= df.format(minQtyT) %>"><i>t</i></div>
                        <div class="unit_kg"><input type="text" name="min_qty_kg" class="inputText" inputmode="decimal" value="<%= df.format(minQtyKg) %>"><i>kg</i></div>
                        <div class="unit_g"><input type="text" name="min_qty_g" class="inputText" inputmode="decimal" value="<%= df.format(minQtyG) %>"><i>g</i></div>
                        <div class="unit_mg"><input type="text" name="min_qty_mg" class="inputText" inputmode="decimal" value="<%= df.format(minQtyMg) %>"><i>mg</i></div>
                    </dd></dl>

                    <div class="bottom_btns">
                        <button type="button" class="Button bgGray" onclick="history.back();" data-width="180">취소</button>
                        <button type="submit" class="Button bgBlue" data-width="180">수정</button>
                    </div>
                </section>
            </form>
        </div>
    </div>
</div>
<script>
    $(document).ready(function() {
        const unitToGram = { 'unit_t': 1000000, 'unit_kg': 1000, 'unit_g': 1, 'unit_mg': 0.001 };
        function formatWithComma(str) {
            if (!str) return '';
            const parts = str.split('.');
            parts[0] = parts[0].replace(/,/g, '').replace(/\B(?=(\d{3})+(?!\d))/g, ',');
            return parts.join('.');
        }
        $(document).on('input', 'input[inputmode="decimal"]', function() {
            let $this = $(this);
            let value = $this.val().replace(/[^0-9.]/g, '');
            $this.val(formatWithComma(value));
            if ($this.closest('dl').hasClass('min')) {
                const $parentGroup = $this.closest('dl');
                const currentUnitClass = $this.parent('div').attr('class').split(' ').find(cls => cls.startsWith('unit_'));
                const numValue = parseFloat(value.replace(/,/g, ''));
                if (isNaN(numValue)) return;
                const baseGrams = numValue * unitToGram[currentUnitClass];
                $.each(unitToGram, function(unitClass, ratio) {
                    if (unitClass !== currentUnitClass) {
                        let calculated = baseGrams / ratio;
                        $parentGroup.find('.' + unitClass + ' input').val(formatWithComma(Number(calculated.toFixed(6)).toString()));
                    }
                });
            }
        });
    });
</script>
<jsp:include page="/app/include/FooterDocType.jsp" />