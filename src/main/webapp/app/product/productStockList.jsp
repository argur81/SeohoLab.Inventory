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
            <div class="content productStockPage">
                <div class="title_set">
                    <h5 class="page_tit">
                        <p>재고현황</p><i><img src="/images/svg/location_arrow.svg"></i><b>제품</b>
                    </h5>
                </div>
                <button type="button" class="new_regist_btn" onclick="location.href='/app/product/productRegist.jsp'">신규등록</button>
                <table id="stockTable" class="display cell-border hover" style="width:100%">
                    <thead>
                        <tr>
                            <th>No</th>
                            <th>종류</th>
                            <th class="name">제품명</th>
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
                                
                                // 회원 테이블(users)과 JOIN하여 이름(user_name) 가져오기
                                String sql = "SELECT p.*, u.user_name "
                                           + "FROM products p "
                                           + "LEFT JOIN users u ON p.last_stock_user_id = u.user_id "
                                           + "ORDER BY p.product_id DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery(); 
                                
                                java.text.DecimalFormat df = new java.text.DecimalFormat("#,##0");
                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");

                                int count = 1; 
                                while(rs.next()) { 
                                    int productId = rs.getInt("product_id");
                                    String productType = rs.getString("product_type");
                                    if (productType == null || productType.trim().isEmpty()) {
                                        productType = "-";
                                    }
                                    
                                    String itemName = rs.getString("item_name");
                                    if (itemName == null) itemName = "";
                                    
                                    int stockQty = rs.getInt("stock_qty");
                                    int minQty = rs.getInt("min_qty");
                                    boolean isLowStock = stockQty < minQty;

                                    String stockDisplay = df.format(stockQty) + " 개";
                                    String minDisplay = df.format(minQty) + " 개";

                                    // 최종 작업자 이름 수신 (이름이 없으면 아이디, 둘 다 없으면 '-')
                                    String lastStockUserName = rs.getString("user_name");
                                    if (lastStockUserName == null || lastStockUserName.trim().isEmpty()) {
                                        lastStockUserName = rs.getString("last_stock_user_id");
                                        if (lastStockUserName == null || lastStockUserName.trim().isEmpty()) {
                                            lastStockUserName = "-";
                                        }
                                    }

                                    Timestamp updatedAt = rs.getTimestamp("updated_at");
                                    String updatedAtDisplay = (updatedAt != null) ? sdf.format(updatedAt) : "-";
                        %>
                        <tr class="<%= isLowStock ? " low-stock" : "" %>">
                            <td>
                                <%= count++ %>
                            </td>
                            <td>
                                <%= productType %>
                            </td>
                            <td>
                                <a href="productModify.jsp?id=<%= productId %>" class="item-link"><%= itemName %></a>
                            </td>
                            <td><%= stockDisplay %></td>
                            <td><%= minDisplay %></td>
                            <td class="state">
                                <%= isLowStock ? "⚠️ 부족" : "정상" %>
                            </td>
                            <td><%= lastStockUserName %></td>
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
                            columnDefs: [
                                { width: "60px", targets: 0, className: "dt-center" },
                                { width: "130px", targets: 1, className: "dt-center" },
                                { width: "120px", targets: 3, className: "dt-right" },
                                { width: "120px", targets: 4, className: "dt-right" },
                                { width: "90px", targets: 5, className: "dt-center" },
                                { width: "120px", targets: 6, className: "dt-center" },
                                { width: "180px", targets: 7, className: "dt-center" },
                            ],
                            responsive: true,
                            language: {
                                emptyTable: "등록된 제품이 없습니다.",
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