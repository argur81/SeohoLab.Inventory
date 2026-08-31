<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String requestIdStr = request.getParameter("request_id");
    int requestId = (requestIdStr != null && !requestIdStr.trim().isEmpty()) ? Integer.parseInt(requestIdStr) : 1;

    String batchNo = "";
    String productName = "";
    double targetQty = 0;
    String targetUnit = "kg";

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

        // 1, 2, 3. request_id를 기반으로 제조지시서 요청 정보 및 제조번호(Lot) 조회
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
                    <p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>진행현황</b><i><img src="/images/svg/location_arrow.svg"></i>제조완료
                </h5>
            </div>
            
            <!-- 충진 및 부자재 처리 폼 -->
            <form id="fillingForm" action="workOrderProgressCompletedAction.jsp" method="post">
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
                    
                    <h5 class="in_tit">부자재 등록</h5>
                    
                    <div id="subsidiaryRowContainer">
                        <!-- 부자재 입력 기본 Row (4, 5번 요구사항) -->
                        <div class="row">
                            <dl class="w50">
                                <dt>부자재명</dt>
                                <dd><input type="text" name="item_name[]" class="inputText sub_item_name" placeholder="자동완성"></dd>
                            </dl>
                            <dl class="w25">
                                <dt>종류</dt>
                                <dd>
                                    <input type="hidden" name="subsidiary_type[]" class="sub_subsidiary_type_hidden">
                                    <select class="og_select sub_subsidiary_type" disabled>
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
                            <dl class="volume stock w25">
                                <dt>사용개수</dt>
                                <dd>
                                    <div class="unit_ea"><input type="text" name="out_qty[]" class="inputText" inputmode="decimal"><i>개</i></div>
                                </dd>
                            </dl>
                        </div>
                    </div>

                    <div class="add_btn">
                        <button type="button" id="addExtraRowBtn" class="Button">부자재 추가</button>
                    </div>
                    <div class="bottom_btns">
                        <button type="button" class="Button bgGray" data-width="180" onclick="location.href='workOrderProgressList.jsp';">목록</button>
                        <button type="submit" id="btnStartFilling" class="Button bgBlue" data-width="180">충진시작</button>
                    </div>
                </section>
            </form>
        </div>
    </div>
</div>

<script>
    $(document).ready(function() {
        // 4. 부자재 자동완성 및 종류 자동 연동 함수 정의
        function initAutocomplete(element) {
            $(element).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        url: "/app/totalRegist/searchItems.jsp",
                        type: "GET",
                        data: {
                            category: "SUBSIDIARY",
                            keyword: request.term
                        },
                        dataType: "json",
                        success: function (data) {
                            response(data);
                        }
                    });
                },
                minLength: 1,
                appendTo: "body",
                select: function (event, ui) {
                    let $row = $(this).closest(".row");
                    $(this).val(ui.item.value); // 자재명 입력
                    
                    let sType = ui.item.type || "";
                    $row.find(".sub_subsidiary_type").val(sType);        // 화면 select 표시용
                    $row.find(".sub_subsidiary_type_hidden").val(sType); // 서버 전송용 hidden 필드
                    
                    return false;
                }
            });
        }

        // 초기 로드된 첫 번째 row에 자동완성 적용
        initAutocomplete(".sub_item_name");

        // 5. 부자재 추가 버튼 누르면 <div class="row"> 증가하여 부자재 추가하기
        $("#addExtraRowBtn").on("click", function() {
            let newRowHtml = `
                <div class="row">
                    <dl class="w50">
                        <dt>부자재명</dt>
                        <dd><input type="text" name="item_name[]" class="inputText sub_item_name" placeholder="자동완성"></dd>
                    </dl>
                    <dl class="w25">
                        <dt>종류</dt>
                        <dd>
                            <input type="hidden" name="subsidiary_type[]" class="sub_subsidiary_type_hidden">
                            <select class="og_select sub_subsidiary_type" disabled>
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
                    <dl class="volume stock w25">
                        <dt>사용개수</dt>
                        <dd>
                            <div class="unit_ea"><input type="text" name="out_qty[]" class="inputText" inputmode="decimal"><i>개</i></div>
                        </dd>
                    </dl>
                </div>
            `;
            let $addedRow = $(newRowHtml);
            $("#subsidiaryRowContainer").append($addedRow);
            
            // 새로 추가된 row의 input에 자동완성 바인딩
            initAutocomplete($addedRow.find(".sub_item_name"));
        });

        // 6. 충진시작 버튼 전송 전 처리 (쉼표 제거 등)
        $("#fillingForm").on("submit", function() {
            $(this).find("input[name='out_qty[]']").each(function() {
                let val = $(this).val().replace(/,/g, '');
                $(this).val(val);
            });
        });
    });
</script>
<jsp:include page="/app/include/FooterDocType.jsp" />