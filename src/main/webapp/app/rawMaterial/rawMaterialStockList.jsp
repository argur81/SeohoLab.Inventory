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
                        <p>원료</p><i><img src="/images/svg/location_arrow.svg"></i><b>재고현황</b>
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

                                java.text.DecimalFormat df = new java.text.DecimalFormat("#,##0.##");
                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");

                                int count = 1; 
                                while(rs.next()) { 
                                    int itemId = rs.getInt("item_id");
                                    String itemName = rs.getString("item_name");
                                    if (itemName == null) itemName = "";

                                    String w1 = rs.getString("work_order_1");
                                    String w2 = rs.getString("work_order_2");
                                    String w3 = rs.getString("work_order_3");
                                    
                                    StringBuilder woSb = new StringBuilder();
                                    if (w1 != null && !w1.trim().isEmpty()) woSb.append(w1.trim());
                                    if (w2 != null && !w2.trim().isEmpty()) {
                                        if (woSb.length() > 0) woSb.append(" / ");
                                        woSb.append(w2.trim());
                                    }
                                    if (w3 != null && !w3.trim().isEmpty()) {
                                        if (woSb.length() > 0) woSb.append(" / ");
                                        woSb.append(w3.trim());
                                    }
                                    String workOrderStr = woSb.length() > 0 ? woSb.toString() : "-";

                                    // DB 단위별 수치 수신
                                    double stockT = rs.getDouble("stock_qty_t");
                                    double stockKg = rs.getDouble("stock_qty_kg");
                                    double stockG = rs.getDouble("stock_qty_g");
                                    double stockMg = rs.getDouble("stock_qty_mg");

                                    double minT = rs.getDouble("min_qty_t");
                                    double minKg = rs.getDouble("min_qty_kg");
                                    double minG = rs.getDouble("min_qty_g");
                                    double minMg = rs.getDouble("min_qty_mg");

                                    // ★ 중복 더하기 제거: kg 수치를 최우선으로 사용하며, 없으면 존재하는 단위 1개만 kg 환산 사용
                                    double finalStockKg = 0;
                                    if (stockKg > 0) finalStockKg = stockKg;
                                    else if (stockT > 0) finalStockKg = stockT * 1000.0;
                                    else if (stockG > 0) finalStockKg = stockG / 1000.0;
                                    else if (stockMg > 0) finalStockKg = stockMg / 1000000.0;

                                    double finalMinKg = 0;
                                    if (minKg > 0) finalMinKg = minKg;
                                    else if (minT > 0) finalMinKg = minT * 1000.0;
                                    else if (minG > 0) finalMinKg = minG / 1000.0;
                                    else if (minMg > 0) finalMinKg = minMg / 1000000.0;

                                    String stockDisplay = df.format(finalStockKg) + " kg";
                                    String minDisplay = df.format(finalMinKg) + " kg";

                                    boolean isLowStock = (finalStockKg < finalMinKg) && (finalMinKg > 0);

                                    Timestamp updatedAt = rs.getTimestamp("updated_at");
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
                                <%= workOrderStr %>
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