<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String requestIdStr = request.getParameter("request_id");
    int requestId = (requestIdStr != null && !requestIdStr.trim().isEmpty()) ? Integer.parseInt(requestIdStr) : 1;

    String batchNo = "";
    String productName = "";
    double targetQty = 0;
    String targetUnit = "kg";

    List<Map<String, Object>> subsidiaryList = new ArrayList<>();

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

        String sql = "SELECT r.product_name, r.target_qty, r.target_unit, m.batch_no "
                + "FROM work_order_requests r "
                + "LEFT JOIN work_order_making m ON r.request_id = m.request_id "
                + "WHERE r.request_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            productName = rs.getString("product_name");
            targetQty = rs.getDouble("target_qty");
            targetUnit = rs.getString("target_unit");
            batchNo = rs.getString("batch_no");
            if (batchNo == null) batchNo = "";
        }
        rs.close();
        pstmt.close();

        String subSql = "SELECT item_name, subsidiary_type, out_qty FROM work_order_subsidiary WHERE request_id = ?";
        pstmt = conn.prepareStatement(subSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            Map<String, Object> item = new HashMap<>();
            item.put("item_name", rs.getString("item_name"));
            item.put("subsidiary_type", rs.getString("subsidiary_type"));
            item.put("out_qty", rs.getDouble("out_qty"));
            subsidiaryList.add(item);
        }

    } catch (Exception e) {
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
        <div class="content workOrderProgressDetail">
            <div class="title_set">
                <h5 class="page_tit">
                    <p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>진행현황</b><i><img src="/images/svg/location_arrow.svg"></i>충진중
                </h5>
            </div>
            
            <form id="completeForm" action="workOrderProgressFillingAction.jsp" method="post">
                <input type="hidden" name="request_id" id="request_id" value="<%= requestId %>">
                <section class="radius subsidiary_reg">
                    <dl class="w25">
                        <dt>Lot</dt>
                        <dd>
                            <input type="hidden" name="batch_no" value="<%= batchNo %>">
                            <input type="text" class="inputText" value="<%= batchNo %>" disabled>
                        </dd>
                    </dl>
                    <dl class="w50">
                        <dt>제품명</dt>
                        <dd>
                            <input type="hidden" name="product_name" value="<%= productName %>">
                            <input type="text" class="inputText" value="<%= productName %>" disabled>
                        </dd>
                    </dl>
                    <dl class="w25">
                        <dt>제조지시량</dt>
                        <dd class="only_text"><%= targetQty %> <%= targetUnit %></dd>
                    </dl>

                    <dl class="w25">
                        <dt>생산수량 <span class="required">*</span></dt>
                        <dd>
                            <div class="unit_ea">
                                <input type="text" name="production_qty" id="production_qty" class="inputText" inputmode="decimal" placeholder="완제품 생산개수 입력" required>
                                <i>개</i>
                            </div>
                        </dd>
                    </dl>
                    <dl class="w25">
                        <dt>제조일자</dt>
                        <dd><input type="date" name="manufacture_date" class="inputText"></dd>
                    </dl>
                    <dl class="w25">
                        <dt>EXP (만료일)</dt>
                        <dd><input type="date" name="expiration_date" class="inputText"></dd>
                    </dl>

                    <h5 class="in_tit">사용한 부자재 목록</h5>
                    
                    <div id="subsidiaryRowContainer">
                        <% if (subsidiaryList.isEmpty()) { %>
                            <div class="row" style="margin-bottom: 10px;">
                                <div style="padding: 10px; color: #777; text-align: center;">등록된 부자재가 없습니다.</div>
                            </div>
                        <% } else { 
                            for (Map<String, Object> sub : subsidiaryList) {
                                String itemName = (String) sub.get("item_name");
                                String subType = (String) sub.get("subsidiary_type");
                                double outQty = (Double) sub.get("out_qty");
                        %>
                            <div class="row" style="margin-bottom: 10px;">
                                <dl class="w50">
                                    <dt>부자재명</dt>
                                    <dd>
                                        <input type="hidden" name="item_name[]" value="<%= itemName %>">
                                        <input type="text" class="inputText" value="<%= itemName %>" disabled>
                                    </dd>
                                </dl>
                                <dl class="w25">
                                    <dt>종류</dt>
                                    <dd>
                                        <input type="hidden" name="subsidiary_type[]" value="<%= subType %>">
                                        <select class="og_select" disabled>
                                            <option value="">선택</option>
                                            <option value="Label" <%= "Label".equals(subType) ? "selected" : "" %>>Label</option>
                                            <option value="Bottle" <%= "Bottle".equals(subType) ? "selected" : "" %>>Bottle</option>
                                            <option value="Pump" <%= "Pump".equals(subType) ? "selected" : "" %>>Pump</option>
                                            <option value="Cap" <%= "Cap".equals(subType) ? "selected" : "" %>>Cap</option>
                                            <option value="Box" <%= "Box".equals(subType) ? "selected" : "" %>>Box</option>
                                            <option value="기타" <%= "기타".equals(subType) ? "selected" : "" %>>기타</option>
                                        </select>
                                    </dd>
                                </dl>
                                <dl class="volume stock w25">
                                    <dt>사용개수</dt>
                                    <dd>
                                        <div class="unit_ea">
                                            <input type="hidden" name="out_qty[]" value="<%= outQty %>">
                                            <input type="text" class="inputText" value="<%= outQty %>" disabled>
                                            <i>개</i>
                                        </div>
                                    </dd>
                                </dl>
                            </div>
                        <% 
                            } 
                        } 
                        %>
                    </div>

                    <div class="bottom_btns">
                        <button type="button" class="Button bgGray" data-width="180" onclick="location.href='workOrderProgressList.jsp';">목록</button>
                        <button type="submit" id="btnComplete" class="Button bgBlue" data-width="180">충진완료</button>
                    </div>
                </section>
            </form>
        </div>
    </div>
</div>
<script>
    $(document).ready(function () {
        function formatWithComma(str) {
            if (!str) return '';
            return str.replace(/,/g, '').replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        }

        $(document).on('input', 'input[inputmode="decimal"]:not([disabled])', function () {
            let value = $(this).val().replace(/[^0-9]/g, '');
            $(this).val(formatWithComma(value));
        });

        $('#completeForm').on('submit', function (e) {
            let rawQty = $('#production_qty').val().replace(/,/g, '');
            if (!rawQty || parseInt(rawQty) <= 0) {
                e.preventDefault();
                alert('생산수량을 입력해 주세요.');
                return false;
            }

            $(this).find('input[inputmode="decimal"]:not([disabled])').each(function () {
                let rawVal = $(this).val().replace(/,/g, '');
                $(this).val(rawVal);
            });
        });
    });
</script>
<jsp:include page="/app/include/FooterDocType.jsp" />
