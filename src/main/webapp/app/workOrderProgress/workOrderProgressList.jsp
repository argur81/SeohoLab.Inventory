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
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
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
            <div class="content workOrderProgressList">
                <div class="title_set">
                    <h5 class="page_tit">
                        <p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>진행현황</b>
                    </h5>
                </div>

                <!-- 화면용 테이블 -->
                <table id="stockTable" class="display cell-border hover" style="width:100%">
                    <thead>
                        <tr>
                            <th>No</th>
                            <th class="name">제품명</th>
                            <th>제조지시량</th>
                            <th>요청일</th>
                            <th>진행현황</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Class.forName("org.mariadb.jdbc.Driver");
                                conn = DriverManager.getConnection(url, dbUser, dbPass);

                                String sql = "SELECT request_id, product_name, target_qty, target_unit, progress_status, request_date "
                                           + "FROM work_order_requests "
                                           + "ORDER BY request_id DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();

                                java.text.DecimalFormat df = new java.text.DecimalFormat("#,##0.###");
                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");

                                int count = 1;
                                while (rs.next()) {
                                    int requestId = rs.getInt("request_id");
                                    String productName = rs.getString("product_name");
                                    if (productName == null) productName = "";

                                    double targetQty = rs.getDouble("target_qty");
                                    String targetUnit = rs.getString("target_unit");
                                    if (targetUnit == null) targetUnit = "";
                                    String targetQtyStr = df.format(targetQty) + " " + targetUnit;

                                    String progressStatus = rs.getString("progress_status");
                                    if (progressStatus == null || progressStatus.trim().isEmpty()) progressStatus = "요청";

                                    String badgeClass = "req";
                                    if ("제조중".equals(progressStatus)) badgeClass = "making";
                                    else if ("제조완료".equals(progressStatus)) badgeClass = "completed";
                                    else if ("충진중".equals(progressStatus)) badgeClass = "filling";
                                    else if ("생산완료".equals(progressStatus)) badgeClass = "done";

                                    Timestamp requestDate = rs.getTimestamp("request_date");
                                    String requestDateDisplay = (requestDate != null) ? sdf.format(requestDate) : "-";
                        %>
                        <tr>
                            <td><%= count++ %></td>
                            <td>
                                <!-- 상세 페이지는 추후 제작 예정 -->
                                <a href="workOrderProgressDetail.jsp?request_id=<%= requestId %>" class="item-link"><%= productName %></a>
                            </td>
                            <td><%= targetQtyStr %></td>
                            <td><%= requestDateDisplay %></td>
                            <td class="dt-center"><span class="progress-badge <%= badgeClass %>"><%= progressStatus %></span></td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            } finally {
                                if (rs != null) try { rs.close(); } catch(Exception e){}
                                if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
                                if (conn != null) try { conn.close(); } catch(Exception e){}
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        $(document).ready(function () {
            var table = $('#stockTable').DataTable({
                autoWidth: false,
                columnDefs: [
                    { width: "80px", targets: 0, className: "dt-center" },
                    { width: "150px", targets: 2, className: "dt-right" },
                    { width: "180px", targets: 3, className: "dt-center" },
                    { width: "120px", targets: 4, className: "dt-center" },
                ],
                responsive: true,
                language: {
                    emptyTable: "등록된 제조요청이 없습니다.",
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
                }
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
<jsp:include page="/app/include/FooterDocType.jsp" />