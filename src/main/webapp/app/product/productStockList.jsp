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
                        <p>재고현황</p><i><img src="/images/svg/location_arrow.svg"></i><b>제품</b>
                    </h5>
                </div>
                <table id="stockTable" class="display cell-border hover" style="width:100%">
                    <thead>
                        <tr>
                            <th>No</th>
                            <th>종류</th>
                            <th class="name">제품명</th>
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
                                
                                // products 테이블에서 최근 수정일 또는 product_id 역순 조회
                                String sql = "SELECT * FROM products ORDER BY product_id DESC"; 
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery(); 
                                
                                // 숫자는 3자리 콤마, 날짜는 YYYY-MM-DD HH:mm 포맷 적용
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
                                    
                                    // 현재 재고 개수 / 최소 재고 개수
                                    int stockQty = rs.getInt("stock_qty"); 
                                    int minQty = rs.getInt("min_qty"); 
                                    boolean isLowStock = stockQty < minQty;

                                    // 표시용 텍스트 (예: 20 개)
                                    String stockDisplay = df.format(stockQty) + " 개";
                                    String minDisplay = df.format(minQty) + " 개";

                                    // 최근 수정일 null 예외 안전 처리
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
                                { width: "80px", targets: 0, className: "dt-center" },
                                { width: "160px", targets: 1, className: "dt-center" },
                                { width: "150px", targets: 3, className: "dt-right" },
                                { width: "150px", targets: 4, className: "dt-right" },
                                { width: "100px", targets: 5, className: "dt-center" },
                                { width: "180px", targets: 6, className: "dt-center" },
                            ],
                            responsive: true, //  반응형 옵션 활성화
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