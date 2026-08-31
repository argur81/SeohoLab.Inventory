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

                                // work_order_making을 LEFT JOIN하여 제조번호(batch_no) 함께 조회
                                String sql = "SELECT r.request_id, r.product_name, r.target_qty, r.target_unit, r.progress_status, r.request_date, m.batch_no "
                                           + "FROM work_order_requests r "
                                           + "LEFT JOIN work_order_making m ON r.request_id = m.request_id "
                                           + "ORDER BY r.request_id DESC";
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

                                    String batchNo = rs.getString("batch_no");

                                    // 상세/작업 페이지 URL 분기
                                    String detailUrl = "workOrderProgressDetail.jsp?request_id=" + requestId;
                                    if ("제조중".equals(progressStatus)) {
                                        detailUrl = "workOrderProgressMaking.jsp?request_id=" + requestId;
                                    } else if ("제조완료".equals(progressStatus)) {
                                        detailUrl = "workOrderProgressCompleted.jsp?request_id=" + requestId;
                                    } else if ("충진중".equals(progressStatus)) {
                                        detailUrl = "workOrderProgressFilling.jsp?request_id=" + requestId;
                                    } else if ("생산완료".equals(progressStatus)) {
                                        detailUrl = "workOrderProgressDone.jsp?request_id=" + requestId;
                                    }

                                    String detailClassname = "regist";
                                    if ("제조중".equals(progressStatus)) {
                                        detailClassname = "making";
                                    } else if ("제조완료".equals(progressStatus)) {
                                        detailClassname = "completed";
                                    } else if ("충진중".equals(progressStatus)) {
                                        detailClassname = "filling";
                                    } else if ("생산완료".equals(progressStatus)) {
                                        detailClassname = "done";
                                    }

                                    String badgeClass = "req";
                                    if ("제조중".equals(progressStatus)) badgeClass = "making";
                                    else if ("제조완료".equals(progressStatus)) badgeClass = "completed";
                                    else if ("충진중".equals(progressStatus)) badgeClass = "filling";
                                    else if ("생산완료".equals(progressStatus)) badgeClass = "done";

                                    // [제조완료/충진중/생산완료] 상태일 때만 제품명 뒤에 제조번호(Lot) 표시
                                    boolean showLot = ("제조완료".equals(progressStatus) || "충진중".equals(progressStatus) || "생산완료".equals(progressStatus))
                                                    && batchNo != null && !batchNo.trim().isEmpty();

                                    Timestamp requestDate = rs.getTimestamp("request_date");
                                    String requestDateDisplay = (requestDate != null) ? sdf.format(requestDate) : "-";
                        %>
                        <tr>
                            <td><%= count++ %></td>
                            <td class="name">
                                <a href="<%= detailUrl %>" class="item-link <%= detailClassname %>">
                                    <%= productName %><% if (showLot) { %> <span class="lot-tag">(<%= batchNo.trim() %>)</span><% } %>
                                </a>
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

                <!-- 엑셀 다운로드 전용 숨겨진 테이블 -->
                <table id="excelExportTable" style="display:none;">
                    <thead>
                        <tr>
                            <th>No</th>
                            <th>제품명</th>
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
                                String sql = "SELECT r.request_id, r.product_name, r.target_qty, r.target_unit, r.progress_status, r.request_date, m.batch_no "
                                        + "FROM work_order_requests r "
                                        + "LEFT JOIN work_order_making m ON r.request_id = m.request_id "
                                        + "ORDER BY r.request_id DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                java.text.DecimalFormat df = new java.text.DecimalFormat("#,##0.###");
                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");

                                int excelCount = 1;
                                while (rs.next()) {
                                    String productName = rs.getString("product_name");
                                    if (productName == null || productName.trim().isEmpty()) continue;

                                    String progressStatus = rs.getString("progress_status");
                                    if (progressStatus == null || progressStatus.trim().isEmpty()) progressStatus = "요청";

                                    String batchNo = rs.getString("batch_no");
                                    boolean showLot = ("제조완료".equals(progressStatus) || "충진중".equals(progressStatus) || "생산완료".equals(progressStatus))
                                                       && batchNo != null && !batchNo.trim().isEmpty();
                                    String displayProductName = showLot ? (productName + " (" + batchNo.trim() + ")") : productName;

                                    double targetQty = rs.getDouble("target_qty");
                                    String targetUnit = rs.getString("target_unit");
                                    String targetQtyStr = df.format(targetQty) + " " + (targetUnit != null ? targetUnit : "");

                                    Timestamp requestDate = rs.getTimestamp("request_date");
                                    String requestDateDisplay = (requestDate != null) ? sdf.format(requestDate) : "-";
                        %>
                        <tr>
                            <td><%= excelCount++ %></td>
                            <td><%= displayProductName %></td>
                            <td><%= targetQtyStr %></td>
                            <td><%= requestDateDisplay %></td>
                            <td><%= progressStatus %></td>
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
                            link.download = '제조지시서_진행현황_' + new Date().toISOString().slice(0,10) + '.xls';
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