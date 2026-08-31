<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
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
            <div class="content rawStatuskPage">
                <div class="title_set">
                    <h5 class="page_tit">
                        <p>품목관리</p><i><img src="/images/svg/location_arrow.svg"></i><b>원료</b>
                    </h5>
                </div>
                <button type="button" class="new_regist_btn" onclick="location.href='/app/rawMaterial/rawMaterialRegist.jsp'">신규등록</button>
                
                <!-- 화면용 테이블 -->
                <table id="stockTable" class="display cell-border hover" style="width:100%">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th class="code">원료코드</th>
                            <th class="name">상품명 (Trade Name)</th>
                            <th>화학명(한글)</th>
                            <th>INCI Name</th>
                            <th>CAS No.</th>
                            <th>공급업체</th>
                            <th>제조사</th>
                            <th>단가구분</th>
                            <th>단가</th>
                            <th>원료추가정보</th>
                            <th>Function</th>
                            <th>Packing 단위</th>
                            <th>rHLB</th>
                            <th>HLB</th>
                            <th>인증</th>
                            <th>유래</th>
                            <th>특이사항</th>
                            <th>연구실명칭</th>
                            <th>최종 처리자</th>
                            <th>Update</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try { 
                                Class.forName("org.mariadb.jdbc.Driver"); 
                                conn = DriverManager.getConnection(url, dbUser, dbPass);
                                
                                // users 테이블과 JOIN하여 user_name 가져오기
                                String sql = "SELECT i.*, u.user_name FROM items i LEFT JOIN users u ON i.user_id = u.user_id WHERE i.category = 'RAW' ORDER BY i.item_id DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery(); 

                                DecimalFormat df = new DecimalFormat("#,##0.##");

                                while(rs.next()) { 
                                    int itemId = rs.getInt("item_id");
                                    String itemCode = rs.getString("item_code") != null ? rs.getString("item_code") : "";
                                    String itemName = rs.getString("item_name") != null ? rs.getString("item_name") : "";
                                    String chemName = rs.getString("chem_name") != null ? rs.getString("chem_name") : "";
                                    String inciName = rs.getString("inci_name") != null ? rs.getString("inci_name") : "";
                                    String casNo = rs.getString("cas_no") != null ? rs.getString("cas_no") : "";
                                    String supplier = rs.getString("supplier") != null ? rs.getString("supplier") : "";
                                    String maker = rs.getString("maker") != null ? rs.getString("maker") : "";
                                    String priceType = rs.getString("price_type") != null ? rs.getString("price_type") : "";
                                    double price = rs.getDouble("price");
                                    String priceDisplay = df.format(price);
                                    String extraInfo = rs.getString("extra_info") != null ? rs.getString("extra_info") : "";
                                    String func = rs.getString("func") != null ? rs.getString("func") : "";
                                    String packingUnit = rs.getString("packing_unit") != null ? rs.getString("packing_unit") : "";
                                    String packingUnitSelect = rs.getString("packing_unit_select") != null ? rs.getString("packing_unit_select") : "";
                                    String packingUnitFull = packingUnit + (!packingUnitSelect.isEmpty() ? " " + packingUnitSelect : "");
                                    String rHlb = rs.getString("r_hlb") != null ? rs.getString("r_hlb") : "";
                                    String hlb = rs.getString("hlb") != null ? rs.getString("hlb") : "";
                                    String certification = rs.getString("certification") != null ? rs.getString("certification") : "";
                                    String origin = rs.getString("origin") != null ? rs.getString("origin") : "";
                                    String note = rs.getString("note") != null ? rs.getString("note") : "";
                                    String labName = rs.getString("lab_name") != null ? rs.getString("lab_name") : "";
                                    
                                    // 최종 처리자 이름과 Update 시간 매핑
                                    String userName = "";
                                    String updatedAt = "";
                                    try { userName = rs.getString("user_name") != null ? rs.getString("user_name") : rs.getString("user_id"); } catch(Exception e) {}
                                    try { updatedAt = rs.getString("updated_at") != null ? rs.getString("updated_at") : ""; } catch(Exception e) {}
                        %>
                        <tr>
                            <td><%= itemId %></td>
                            <td class="code"><%= itemCode %></td>
                            <td class="name">
                                <a href="rawStatusModify.jsp?id=<%= itemId %>" class="item-link"><%= itemName %></a>
                            </td>
                            <td class="chemName"><div class="text" title="<%= chemName %>"><%= chemName %></div></td>
                            <td><%= inciName %></td>
                            <td><%= casNo %></td>
                            <td><%= supplier %></td>
                            <td><%= maker %></td>
                            <td><%= priceType %></td>
                            <td><%= priceDisplay %></td>
                            <td><%= extraInfo %></td>
                            <td><%= func %></td>
                            <td><%= packingUnitFull %></td>
                            <td><%= rHlb %></td>
                            <td><%= hlb %></td>
                            <td><%= certification %></td>
                            <td><%= origin %></td>
                            <td><%= note %></td>
                            <td><%= labName %></td>
                            <td><%= userName %></td>
                            <td><%= updatedAt %></td>
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

                <!-- 엑셀 다운로드 전용 숨겨진 테이블 ([ID], [최종 처리자], [Update] 제외) -->
                <table id="excelExportTable" style="display:none;">
                    <thead>
                        <tr>
                            <th>원료코드</th>
                            <th>상품명 (Trade Name)</th>
                            <th>화학명(한글)</th>
                            <th>INCI Name</th>
                            <th>CAS No.</th>
                            <th>공급업체</th>
                            <th>제조사</th>
                            <th>단가구분</th>
                            <th>단가</th>
                            <th>원료추가정보</th>
                            <th>Function</th>
                            <th>Packing 단위</th>
                            <th>rHLB</th>
                            <th>HLB</th>
                            <th>인증</th>
                            <th>유래</th>
                            <th>특이사항</th>
                            <th>연구실명칭</th>
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
                                DecimalFormat df = new DecimalFormat("#,##0.##");

                                while(rs.next()) { 
                                    String itemCode = rs.getString("item_code") != null ? rs.getString("item_code") : "";
                                    String itemName = rs.getString("item_name") != null ? rs.getString("item_name") : "";
                                    // 상품명이 비어있는 경우 빈 행 생성을 방지하기 위해 스킵 처리
                                    if(itemName.isEmpty()) continue;

                                    String chemName = rs.getString("chem_name") != null ? rs.getString("chem_name") : "";
                                    String inciName = rs.getString("inci_name") != null ? rs.getString("inci_name") : "";
                                    String casNo = rs.getString("cas_no") != null ? rs.getString("cas_no") : "";
                                    String supplier = rs.getString("supplier") != null ? rs.getString("supplier") : "";
                                    String maker = rs.getString("maker") != null ? rs.getString("maker") : "";
                                    String priceType = rs.getString("price_type") != null ? rs.getString("price_type") : "";
                                    double price = rs.getDouble("price");
                                    String priceDisplay = df.format(price);
                                    String extraInfo = rs.getString("extra_info") != null ? rs.getString("extra_info") : "";
                                    String func = rs.getString("func") != null ? rs.getString("func") : "";
                                    String packingUnit = rs.getString("packing_unit") != null ? rs.getString("packing_unit") : "";
                                    String packingUnitSelect = rs.getString("packing_unit_select") != null ? rs.getString("packing_unit_select") : "";
                                    String packingUnitFull = packingUnit + (!packingUnitSelect.isEmpty() ? " " + packingUnitSelect : "");
                                    String rHlb = rs.getString("r_hlb") != null ? rs.getString("r_hlb") : "";
                                    String hlb = rs.getString("hlb") != null ? rs.getString("hlb") : "";
                                    String certification = rs.getString("certification") != null ? rs.getString("certification") : "";
                                    String origin = rs.getString("origin") != null ? rs.getString("origin") : "";
                                    String note = rs.getString("note") != null ? rs.getString("note") : "";
                                    String labName = rs.getString("lab_name") != null ? rs.getString("lab_name") : "";
                        %>
                        <tr>
                            <td><%= itemCode %></td>
                            <td><%= itemName %></td>
                            <td><%= chemName %></td>
                            <td><%= inciName %></td>
                            <td><%= casNo %></td>
                            <td><%= supplier %></td>
                            <td><%= maker %></td>
                            <td><%= priceType %></td>
                            <td><%= priceDisplay %></td>
                            <td><%= extraInfo %></td>
                            <td><%= func %></td>
                            <td><%= packingUnitFull %></td>
                            <td><%= rHlb %></td>
                            <td><%= hlb %></td>
                            <td><%= certification %></td>
                            <td><%= origin %></td>
                            <td><%= note %></td>
                            <td><%= labName %></td>
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
                                // 화면에서 기본 숨김 처리할 컬럼 인덱스
                                { targets: [4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18], visible: false },
                                { width: "80px", targets: 0, className: "dt-center" }, // ID
                                { width: "120px", targets: 1, className: "dt-center" }, // 원료코드
                                { width: "350px", targets: 3, },  // 한글명
                                { width: "150px", targets: 9, className: "dt-right" },  // 단가
                                { width: "120px", targets: 19, className: "dt-center" },  // 작성자
                                { width: "180px", targets: 20, className: "dt-right" },  // 업데이트
                                { targets: [1], className: 'min-tablet'},
                            ],
                            responsive: true,
                            language: {
                                emptyTable: "등록된 원료가 없습니다.",
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
                            order: [[0, 'desc']],
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

                            // [수정된 부분] 헤더 구성
                            html += '<thead><tr>';
                            $('#excelExportTable thead th').each(function () {
                                html += '<th>' + $(this).text() + '</th>';
                            });
                            html += '</tr></thead>';

                            // [수정된 부분] 바디 구성 및 빈 행 방지 필터링
                            html += '<tbody>';
                            $('#excelExportTable tbody tr').each(function () {
                                let rowText = "";
                                $(this).find('td').each(function () {
                                    rowText += $(this).text();
                                });

                                // 데이터가 존재하는 행만 엑셀 테이블에 포함
                                if (rowText.trim() !== "") {
                                    html += '<tr>';
                                    $(this).find('td').each(function () {
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
                            link.download = '원료목록_' + new Date().toISOString().slice(0, 10) + '.xls';
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