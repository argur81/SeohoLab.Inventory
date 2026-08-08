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
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content rawStockPage">
                <div class="title_set">
                    <h5 class="page_tit">
                        <p>원료</p><i><img src="/images/svg/location_arrow.svg"></i>재고
                    </h5>
                </div>
                <table id="stockTable" class="display cell-border hover" style="width:100%">
                    <thead>
                        <tr>
                            <th>No</th>
                            <th>원료명</th>
                            <th>작업지시서1~3</th>
                            <th>현재 재고량</th>
                            <th>최소 재고량</th>
                            <th>상태</th>
                            <th>최근 수정일</th>
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
                            
                            // 포맷터 정의 (3자리 콤마 + 날짜 포맷)
                            java.text.DecimalFormat df = new java.text.DecimalFormat("#,##0.######");
                            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");

                            int count = 1; 
                            while(rs.next()) { 
                                String itemName = rs.getString("item_name"); 
                                String wo1 = rs.getString("work_order_1") != null ? rs.getString("work_order_1") : ""; 
                                String wo2 = rs.getString("work_order_2") != null ? rs.getString("work_order_2") : ""; 
                                String wo3 = rs.getString("work_order_3") != null ? rs.getString("work_order_3") : ""; 
                                String lot = rs.getString("lot_number");
                                Date receiptDate = rs.getDate("receipt_date"); 
                                Date expDate = rs.getDate("expiration_date"); 
                                
                                // 총합 kg 수치 및 상태 판단
                                double totalStockKg = rs.getDouble("total_stock_kg"); 
                                double totalMinKg = rs.getDouble("total_min_kg"); 
                                boolean isLowStock = totalStockKg < totalMinKg;

                                // 1. kg 단위 표기 생성 (예: "30 kg")
                                String stockDisplay = df.format(totalStockKg) + " kg";
                                String minDisplay = df.format(totalMinKg) + " kg";

                                // 2. 최근 수정일 조회 및 포맷팅 (null 처리)
                                java.sql.Timestamp updatedAt = rs.getTimestamp("updated_at");
                                String updatedAtDisplay = (updatedAt != null) ? sdf.format(updatedAt) : "-";
                    %>
                        <tr class="<%= isLowStock ? " low-stock" : "" %>">
                            <td>
                                <%= count++ %>
                            </td>
                            <td>
                                <a href="rawMaterialModify.jsp?id=<%= rs.getInt("item_id") %>" class="item-link"><%= itemName %></a>
                            </td>
                            <td>
                                <%= wo1 %>
                                <%= !wo2.isEmpty() ? " / " + wo2 : "" %>
                                <%= !wo3.isEmpty() ? " / " + wo3 : "" %>
                            </td>
                            <td><%= stockDisplay %></td>
                            <td><%= minDisplay %></td>
                            <td class="state">
                                <%= isLowStock ? "⚠️ 부족" : "정상" %>
                            </td>
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
                        $('#stockTable').DataTable({
                            autoWidth: false,
                            //3번째 열(인덱스 2: 작업지시서)을 화면에서 숨김 처리 (검색은 그대로 작동함)
                            columnDefs: [
                                { targets: [2], visible: false },
                                { width: "80px", targets: 0, className: "dt-center" },
                                { width: "150px", targets: 3, className: "dt-right" },
                                { width: "150px", targets: 4, className: "dt-right" },
                                { width: "100px", targets: 5, className: "dt-center" },
                                { width: "180px", targets: 6, className: "dt-center" },
                            ],
                            responsive: true, //  반응형 옵션 활성화
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
                            pageLength: 25,
                            order: [[0, 'asc']]
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