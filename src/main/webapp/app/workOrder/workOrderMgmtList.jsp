<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // DB 연결 설정
    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
%>
<style>
    /* [Style] 로딩 오버레이 디자인 */
    #loadingOverlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(255, 255, 255, 1);
        z-index: 9999;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }

    /* [Style] 로딩 스피너 애니메이션 */
    .spinner {
        width: 50px;
        height: 50px;
        border: 5px solid #f3f3f3;
        border-top: 5px solid #3498db;
        border-radius: 50%;
        animation: spin 1s linear infinite;
    }

    .loading_text {
        margin-top: 15px;
        font-weight: bold;
        color: #333;
        font-size: 14px;
    }

    @keyframes spin {
        0% {
            transform: rotate(0deg);
        }
        100% {
            transform: rotate(360deg);
        }
    }
</style>
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <!-- 로딩 오버레이 -->
    <div id="loadingOverlay">
        <div class="spinner"></div>
        <p class="loading_text">데이터를 불러오는 중입니다...</p>
    </div>
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content workOrderList">
                <div class="title_set">
                    <h5 class="page_tit">
                        <p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>관리·신규등록</b>
                    </h5>
                </div>
                <button type="button" class="new_regist_btn" onclick="location.href='/app/workOrder/workOrderRegist.jsp'">신규등록</button>
                
                <!-- 화면용 테이블 -->
                <table id="stockTable" class="display cell-border hover" style="width:100%">
                    <thead>
                        <tr>
                            <th>No</th>
                            <th class="name">제품명</th>
                            <th>제조지시량</th>
                            <th>합계단가</th>
                            <th>Update</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try { 
                                Class.forName("org.mariadb.jdbc.Driver"); 
                                conn = DriverManager.getConnection(url, dbUser, dbPass);
                                
                                // status 컬럼 추가 조회
                                String sql = "SELECT o.order_id, o.product_name, o.target_qty, o.target_unit, o.created_at, o.status, "
                                           + "COALESCE(SUM(i.unit_price), 0) as total_price "
                                           + "FROM work_orders o "
                                           + "LEFT JOIN work_order_items i ON o.order_id = i.order_id "
                                           + "GROUP BY o.order_id, o.product_name, o.target_qty, o.target_unit, o.created_at, o.status "
                                           + "ORDER BY o.order_id DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery(); 
                                
                                java.text.DecimalFormat df = new java.text.DecimalFormat("#,##0");
                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");

                                int count = 1; 
                                while(rs.next()) { 
                                    int orderId = rs.getInt("order_id");
                                    String productName = rs.getString("product_name");
                                    if (productName == null) productName = "";
                                    
                                    // 임시저장 상태인 경우 제품명 앞에 [임시저장] 말머리 추가
                                    String status = rs.getString("status");
                                    String displayProductName = productName;
                                    if (status != null && status.equals("TEMP")) {
                                        displayProductName = "[임시저장] " + productName;
                                    }
                                    
                                    double targetQty = rs.getDouble("target_qty");
                                    String targetUnit = rs.getString("target_unit");
                                    if (targetUnit == null) targetUnit = "";
                                    String targetQtyStr = targetQty + " " + targetUnit;

                                    double totalPrice = rs.getDouble("total_price");
                                    String totalPriceStr = df.format(Math.round(totalPrice)) + "원";

                                    Timestamp updatedAt = rs.getTimestamp("created_at");
                                    String updatedAtDisplay = (updatedAt != null) ? sdf.format(updatedAt) : "-";
                        %>
                        <tr>
                            <td><%= count++ %></td>
                            <td>
                                <a href="workOrderModify.jsp?order_id=<%= orderId %>" class="item-link"><%= displayProductName %></a>
                            </td>
                            <td><%= targetQtyStr %></td>
                            <td><%= totalPriceStr %></td>
                            <td><%= updatedAtDisplay %></td>
                        </tr>
                        <% 
                            } 
                            } catch(Exception e) { 
                                e.printStackTrace(); 
                            } finally { 
                                if(rs != null) try { rs.close(); } catch(Exception e){} 
                                if(pstmt != null) try { pstmt.close(); } catch(Exception e){} 
                                if(conn != null) try { conn.close(); } catch(Exception e){} 
                            } 
                        %>
                    </tbody>
                </table>

                <!-- 엑셀 다운로드 전용 숨겨진 테이블 -->
                <table id="excelExportTable" style="display:none;">
                    <thead>
                        <tr>
                            <th>No</th>
                            <th>제품명</th>
                            <th>제조지시량</th>
                            <th>합계단가</th>
                            <th>Update</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try { 
                                Class.forName("org.mariadb.jdbc.Driver"); 
                                conn = DriverManager.getConnection(url, dbUser, dbPass);
                                String sql = "SELECT o.order_id, o.product_name, o.target_qty, o.target_unit, o.created_at, o.status, "
                                        + "COALESCE(SUM(i.unit_price), 0) as total_price "
                                        + "FROM work_orders o "
                                        + "LEFT JOIN work_order_items i ON o.order_id = i.order_id "
                                        + "GROUP BY o.order_id, o.product_name, o.target_qty, o.target_unit, o.created_at, o.status "
                                        + "ORDER BY o.order_id DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery(); 
                                java.text.DecimalFormat df = new java.text.DecimalFormat("#,##0");
                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");

                                int excelCount = 1;
                                while(rs.next()) { 
                                    String productName = rs.getString("product_name");
                                    if (productName == null || productName.trim().isEmpty()) continue;

                                    String status = rs.getString("status");
                                    String displayProductName = productName;
                                    if (status != null && status.equals("TEMP")) {
                                        displayProductName = "[임시저장] " + productName;
                                    }

                                    double targetQty = rs.getDouble("target_qty");
                                    String targetUnit = rs.getString("target_unit");
                                    String targetQtyStr = targetQty + " " + (targetUnit != null ? targetUnit : "");

                                    double totalPrice = rs.getDouble("total_price");
                                    String totalPriceStr = df.format(Math.round(totalPrice)) + "원";

                                    Timestamp updatedAt = rs.getTimestamp("created_at");
                                    String updatedAtDisplay = (updatedAt != null) ? sdf.format(updatedAt) : "-";
                        %>
                        <tr>
                            <td><%= excelCount++ %></td>
                            <td><%= displayProductName %></td>
                            <td><%= targetQtyStr %></td>
                            <td><%= totalPriceStr %></td>
                            <td><%= updatedAtDisplay %></td>
                        </tr>
                        <% 
                                } 
                            } catch(Exception e) { 
                                e.printStackTrace(); 
                            } finally { 
                                if(rs != null) try { rs.close(); } catch(Exception e){} 
                                if(pstmt != null) try { pstmt.close(); } catch(Exception e){} 
                                if(conn != null) try { conn.close(); } catch(Exception e){} 
                            } 
                        %>
                    </tbody>
                </table>

                <script>
                    $(document).ready(function () {
                        var table = $('#stockTable').DataTable({
                            autoWidth: false,
                            columnDefs: [
                                { width: "80px", targets: 0, className: "dt-center" },
                                { width: "130px", targets: 2, className: "dt-right" },
                                { width: "130px", targets: 3, className: "dt-right" },
                                { width: "180px", targets: 4, className: "dt-center" },
                            ],
                            responsive: true,
                            language: {
                                emptyTable: "등록된 제조 지시서가 없습니다.",
                                lengthMenu: "_MENU_ 개씩 보기",
                                info: "총 <i>_TOTAL_</i>개 중 _START_ - _END_",
                                infoEmpty: "데이터 없음",
                                infoFiltered: "(전체 _MAX_개 중 검색됨)",
                                search: "검색",
                                zeroRecords: "검색 결과가 없습니다.",
                                paginate: {
                                    first: "처음",
                                    last: "마지막",
                                    next: "다음",
                                    previous: "이전"
                                }
                            },
                            pageLength: 25,
                            order: [[0, 'asc']],
                            initComplete: function (settings, json) {
                                $('#loadingOverlay').fadeOut(1000);
                                
                                // lengthMenu 영역 안에 엑셀 다운로드 버튼 삽입
                                $('<button type="button" class="Button" id="excelBtn"><img src="/images/svg/file-excel-regular-full.svg">엑셀 다운로드</button>')
                                    .appendTo('.dataTables_length');
                            }
                        });

                        // 엑셀 다운로드 동작 이벤트
                        $(document).on('click', '#excelBtn', function () {
                            let html = '<html><head><meta charset="utf-8"/></head><body>';
                            html += '<table border="1">';
                            
                            html += '<thead><tr>';
                            $('#excelExportTable thead th').each(function() {
                                html += '<th>' + $(this).text() + '</th>';
                            });
                            html += '</tr></thead>';
                            
                            html += '<tbody>';
                            $('#excelExportTable tbody tr').each(function() {
                                let rowText = "";
                                $(this).find('td').each(function() {
                                    rowText += $(this).text();
                                });
                                
                                if (rowText.trim() !== "") {
                                    html += '<tr>';
                                    $(this).find('td').each(function() {
                                        html += '<td>' + $(this).text() + '</td>';
                                    });
                                    html += '</tr>';
                                }
                            });
                            html += '</tbody>';
                            
                            html += '</table></body></html>';

                            let blob = new Blob([html], { type: 'application/vnd.ms-excel;charset=utf-8;' });
                            let link = document.createElement('a');
                            link.href = URL.createObjectURL(blob);
                            link.download = '제조지시서_관리_' + new Date().toISOString().slice(0,10) + '.xls';
                            link.click();
                        });

                        $('.dataTables_wrapper > .dataTables_length, .dataTables_wrapper > .dataTables_filter').wrapAll('<div class="top_group"></div>');
                        $('.dataTables_wrapper > .dataTables_info, .dataTables_wrapper > .dataTables_paginate').wrapAll('<div class="bottom_group"></div>');
                        
                        function dataTableForMoblie() {
                            if ($(window).width() <= 780) {
                                $('.dataTables_wrapper table.dataTable thead tr th').removeClass('last_th');
                                $('th.dtr-hidden').first().prev('th').addClass('last_th');
                                $('.dataTables_wrapper table.dataTable tbody tr').each(function(){
                                    $(this).find('td').removeClass('last_td');
                                    $(this).find('td.dtr-hidden').first().prev('td').addClass('last_td');
                                });
                            } else {
                                $('.dataTables_wrapper table.dataTable thead tr th').removeClass('last_th');
                                $('.dataTables_wrapper table.dataTable tbody tr td').removeClass('last_td');
                            }
                        }
                        dataTableForMoblie();
                        $(window).resize(function () {
                            dataTableForMoblie();
                        });
                    });
                </script>
            </div>
        </div>
    </div>
<jsp:include page="/app/include/FooterDocType.jsp" />