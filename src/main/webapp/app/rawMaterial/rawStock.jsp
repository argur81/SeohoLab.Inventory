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
                            <th>Lot번호</th>
                            <th>입고일</th>
                            <th>만료일</th>
                            <th>현재 재고량</th>
                            <th>최소 재고량</th>
                            <th>상태</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% try { Class.forName("org.mariadb.jdbc.Driver"); conn=DriverManager.getConnection(url, dbUser, dbPass);
                            String sql="SELECT * FROM items WHERE category = 'RAW' ORDER BY item_id DESC" ; pstmt=conn.prepareStatement(sql);
                            rs=pstmt.executeQuery(); int count=1; while(rs.next()) { String itemName=rs.getString("item_name"); String
                            wo1=rs.getString("work_order_1") !=null ? rs.getString("work_order_1") : "" ; String
                            wo2=rs.getString("work_order_2") !=null ? rs.getString("work_order_2") : "" ; String
                            wo3=rs.getString("work_order_3") !=null ? rs.getString("work_order_3") : "" ; String
                            lot=rs.getString("lot_number"); Date receiptDate=rs.getDate("receipt_date"); Date
                            expDate=rs.getDate("expiration_date"); double stockT=rs.getDouble("stock_qty_t"); double
                            stockKg=rs.getDouble("stock_qty_kg"); double stockG=rs.getDouble("stock_qty_g"); double
                            stockMg=rs.getDouble("stock_qty_mg"); double minT=rs.getDouble("min_qty_t"); double
                            minKg=rs.getDouble("min_qty_kg"); double minG=rs.getDouble("min_qty_g"); double
                            minMg=rs.getDouble("min_qty_mg"); double totalStockKg=rs.getDouble("total_stock_kg"); double
                            totalMinKg=rs.getDouble("total_min_kg"); boolean isLowStock=totalStockKg < totalMinKg; %>
                            <tr class="<%= isLowStock ? " low-stock" : "" %>">
                                <td>
                                    <%= count++ %>
                                </td>
                                <td>
                                    <a href="rawModify.jsp?id=<%= rs.getInt("item_id") %>" class="item-link"><%= itemName %></a>
                                </td>
                                <td>
                                    <%= wo1 %>
                                    <%= !wo2.isEmpty() ? " / " + wo2 : "" %>
                                    <%= !wo3.isEmpty() ? " / " + wo3 : "" %>
                                </td>
                                <td>
                                    <%= lot %>
                                </td>
                                <td>
                                    <%= receiptDate !=null ? receiptDate : "-" %>
                                </td>
                                <td>
                                    <%= expDate !=null ? expDate : "-" %>
                                </td>
                                <%  // 1. 현재 재고량 단위 조합 (/ 구분자) 
                                    java.util.List<String> stockList = new java.util.ArrayList<String>();
                                        if (stockT > 0) stockList.add(stockT + "t");
                                        if (stockKg > 0) stockList.add(stockKg + "kg");
                                        if (stockG > 0) stockList.add(stockG + "g");
                                        if (stockMg > 0) stockList.add(stockMg + "mg");
                                        String stockDisplay = stockList.isEmpty() ? "0 kg" : String.join(" / ", stockList);
                                
                                    // 2. 최소 재고량 단위 조합 (/ 구분자)
                                    java.util.List<String> minList = new java.util.ArrayList<String>();
                                        if (minT > 0) minList.add(minT + "t");
                                        if (minKg > 0) minList.add(minKg + "kg");
                                        if (minG > 0) minList.add(minG + "g");
                                        if (minMg > 0) minList.add(minMg + "mg");
                                        String minDisplay = minList.isEmpty() ? "0 kg" : String.join(" / ", minList);
                                %>
                                <td><%= stockDisplay %></td>
                                <td><%= minDisplay %></td>
                                <td class="state">
                                    <%= isLowStock ? "⚠️ 부족" : "정상" %>
                                </td>
                            </tr>
                            <% } } catch(Exception e) { e.printStackTrace(); } finally { if(rs !=null) try { rs.close(); } catch(Exception
                                e){} if(pstmt !=null) try { pstmt.close(); } catch(Exception e){} if(conn !=null) try { conn.close(); }
                                catch(Exception e){} } %>
                    </tbody>
                </table>
                <script>
                    $(document).ready(function () {
                        $('#stockTable').DataTable({
                            autoWidth: false,
                            //3번째 열(인덱스 2: 작업지시서)을 화면에서 숨김 처리 (검색은 그대로 작동함)
                            columnDefs: [
                                { targets: [2,3,4,5], visible: false }
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
                                $('.dataTables_wrapper table.dataTable tbody tr td').removeClass('last_td');
                                $('th.dtr-hidden').first().prev('th').addClass('last_th');
                                $('td.dtr-hidden').first().prev('td').addClass('last_td');
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