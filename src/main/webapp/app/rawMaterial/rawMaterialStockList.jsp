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
<jsp:include page="/app/include/HeaderDocType.jsp" />
    <!-- 로딩 오버레이 -->
    <div id="loadingOverlay">
        <div class="spinner"></div>
        <p class="loading_text">데이터를 불러오는 중입니다...</p>
    </div>
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content rawStockPage">
                <div class="title_set">
                    <h5 class="page_tit">
                        <p>재고현황</p><i><img src="/images/svg/location_arrow.svg"></i><b>원료</b>
                    </h5>
                </div>
                <button type="button" class="new_regist_btn" onclick="location.href='/app/rawMaterial/rawMaterialRegist.jsp'">신규등록</button>
                
                <!-- 화면용 테이블 -->
                <table id="stockTable" class="display cell-border hover" style="width:100%">
                    <thead>
                        <tr>
                            <th>No</th>
                            <th class="name">원료명</th>
                            <th>작업지시서1~2</th>
                            <th>화학명(한글)</th>
                            <th>현재 재고량</th>
                            <th>최소 재고량</th>
                            <th>상태</th>
                            <th>최종 처리자</th>
                            <th>Update</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try { 
                                Class.forName("org.mariadb.jdbc.Driver"); 
                                conn = DriverManager.getConnection(url, dbUser, dbPass);
                                
                                String sql = "SELECT i.*, u.user_name FROM items i " +
                                            "LEFT JOIN users u ON i.last_stock_user_id = u.user_id " +
                                            "WHERE i.category = 'RAW' ORDER BY i.item_id DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery(); 

                                java.text.DecimalFormat df = new java.text.DecimalFormat("#,##0.##");
                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");

                                int count = 1; 
                                while(rs.next()) { 
                                    int itemId = rs.getInt("item_id");
                                    String itemName = rs.getString("item_name");
                                    if (itemName == null) itemName = "";

                                    String w1 = rs.getString("work_order_1");
                                    String w2 = rs.getString("work_order_2");
                                    
                                    StringBuilder woSb = new StringBuilder();
                                    if (w1 != null && !w1.trim().isEmpty()) woSb.append(w1.trim());
                                    if (w2 != null && !w2.trim().isEmpty()) {
                                        if (woSb.length() > 0) woSb.append(" / ");
                                        woSb.append(w2.trim());
                                    }
                                    String workOrderStr = woSb.length() > 0 ? woSb.toString() : "-";

                                    String chemName = rs.getString("chem_name");
                                    if (chemName == null) chemName = "";

                                    double stockT = rs.getDouble("stock_qty_t");
                                    double stockKg = rs.getDouble("stock_qty_kg");
                                    double stockG = rs.getDouble("stock_qty_g");
                                    double stockMg = rs.getDouble("stock_qty_mg");

                                    double finalStockKg = 0;
                                    if (stockKg > 0) finalStockKg = stockKg;
                                    else if (stockT > 0) finalStockKg = stockT * 1000.0;
                                    else if (stockG > 0) finalStockKg = stockG / 1000.0;
                                    else if (stockMg > 0) finalStockKg = stockMg / 1000000.0;

                                    double finalMinKg = rs.getDouble("total_min_kg");

                                    String stockDisplay = df.format(finalStockKg) + " kg";
                                    String minDisplay = df.format(finalMinKg) + " kg";

                                    boolean isLowStock = (finalStockKg < finalMinKg) && (finalMinKg > 0);
                                    String statusStr = isLowStock ? "⚠️ 부족" : "정상";

                                    String userName = rs.getString("user_name");
                                    if (userName == null || userName.trim().isEmpty()) {
                                        userName = "-";
                                    }

                                    Timestamp updatedAt = rs.getTimestamp("updated_at");
                                    String updatedAtDisplay = (updatedAt != null) ? sdf.format(updatedAt) : "-";
                        %>
                        <tr class="<%= isLowStock ? " low-stock" : "" %>">
                            <td><%= count++ %></td>
                            <td>
                                <a href="rawMaterialModify.jsp?id=<%= itemId %>" class="item-link"><%= itemName %></a>
                            </td>
                            <td><%= workOrderStr %></td>
                            <td><%= chemName %></td>
                            <td><%= stockDisplay %></td>
                            <td><%= minDisplay %></td>
                            <td class="state">
                                <%= statusStr %>
                            </td>
                            <td><%= userName %></td>
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

                <!-- 엑셀 다운로드 전용 숨겨진 테이블 ([원료명], [현재재고량], [최소재고량], [상태]) -->
                <table id="excelExportTable" style="display:none;">
                    <thead>
                        <tr>
                            <th>원료명</th>
                            <th>현재재고량</th>
                            <th>최소재고량</th>
                            <th>상태</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try { 
                                Class.forName("org.mariadb.jdbc.Driver"); 
                                conn = DriverManager.getConnection(url, dbUser, dbPass);
                                String sql = "SELECT * FROM items WHERE category = 'RAW' ORDER BY item_id DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery(); 
                                java.text.DecimalFormat df = new java.text.DecimalFormat("#,##0.##");

                                while(rs.next()) { 
                                    String itemName = rs.getString("item_name");
                                    if (itemName == null) itemName = "";
                                    if (itemName.isEmpty()) continue; // 빈 행 방지

                                    double stockT = rs.getDouble("stock_qty_t");
                                    double stockKg = rs.getDouble("stock_qty_kg");
                                    double stockG = rs.getDouble("stock_qty_g");
                                    double stockMg = rs.getDouble("stock_qty_mg");

                                    double finalStockKg = 0;
                                    if (stockKg > 0) finalStockKg = stockKg;
                                    else if (stockT > 0) finalStockKg = stockT * 1000.0;
                                    else if (stockG > 0) finalStockKg = stockG / 1000.0;
                                    else if (stockMg > 0) finalStockKg = stockMg / 1000000.0;

                                    double finalMinKg = rs.getDouble("total_min_kg");

                                    String stockDisplay = df.format(finalStockKg) + " kg";
                                    String minDisplay = df.format(finalMinKg) + " kg";

                                    boolean isLowStock = (finalStockKg < finalMinKg) && (finalMinKg > 0);
                                    String statusStr = isLowStock ? "부족" : "정상";
                        %>
                        <tr>
                            <td><%= itemName %></td>
                            <td><%= stockDisplay %></td>
                            <td><%= minDisplay %></td>
                            <td><%= statusStr %></td>
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
                                { targets: [2, 3], visible: false }, // 작업지시서(2번)와 화학명(3번) 화면 숨김 처리 및 검색 가능 유지
                                { width: "70px", targets: 0, className: "dt-center" },
                                { width: "130px", targets: 4, className: "dt-right" },
                                { width: "130px", targets: 5, className: "dt-right" },
                                { width: "90px", targets: 6, className: "dt-center" },
                                { width: "120px", targets: 7, className: "dt-center" },
                                { width: "180px", targets: 8, className: "dt-center" },
                            ],
                            responsive: true,
                            language: {
                                emptyTable: "등록된 원료 재고가 없습니다.",
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
                            pageLength: 100,
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
                            
                            // 헤더 구성
                            html += '<thead><tr>';
                            $('#excelExportTable thead th').each(function() {
                                html += '<th>' + $(this).text() + '</th>';
                            });
                            html += '</tr></thead>';
                            
                            // 바디 구성 및 빈 행 방지 필터링
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
                            link.download = '재고현황_원료_' + new Date().toISOString().slice(0,10) + '.xls';
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