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
    Statement stmt = null;
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
            <div class="content lotStatusPage">
                <div class="title_set">
                    <h5 class="page_tit">
                        <p>품목관리</p><i><img src="/images/svg/location_arrow.svg"></i><b>Lot</b>
                    </h5>
                </div>
                
                <!-- 화면용 테이블 -->
                <table id="stockTable" class="display cell-border hover" style="width:100%">
                    <thead>
                        <tr>
                            <th>No</th>
                            <th>카테고리</th>
                            <th>Lot번호</th>
                            <th class="name">원료/제품명</th>
                            <th>현재 재고량</th>
                            <th>최종 수정일</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try { 
                                Class.forName("org.mariadb.jdbc.Driver"); 
                                conn = DriverManager.getConnection(url, dbUser, dbPass);
                                stmt = conn.createStatement();
                                
                                String sql = "SELECT '원료' AS category, lot_id, item_name, lot_number, "
                                        + "CONCAT(FORMAT(stock_qty_kg, 2), ' kg ') AS stock_qty, updated_at "
                                        + "FROM item_lots "
                                        + "UNION ALL "
                                        + "SELECT '제품' AS category, lot_id, item_name, lot_number, "
                                        + "CONCAT(FORMAT(stock_qty, 0), ' 개') AS stock_qty, updated_at "
                                        + "FROM product_lots "
                                        + "ORDER BY updated_at DESC";
                                
                                rs = stmt.executeQuery(sql);
                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");

                                int count = 1; 
                                while(rs.next()) { 
                                    String category = rs.getString("category");
                                    int lotId = rs.getInt("lot_id");
                                    String itemName = rs.getString("item_name") != null ? rs.getString("item_name") : "";
                                    String lotNumber = rs.getString("lot_number") != null ? rs.getString("lot_number") : "";
                                    String stockQty = rs.getString("stock_qty") != null ? rs.getString("stock_qty") : "0";
                                    Timestamp updatedAt = rs.getTimestamp("updated_at");
                                    String updatedAtDisplay = (updatedAt != null) ? sdf.format(updatedAt) : "-";

                                    String modifyPage = category.equals("원료") ? "lotRawModify.jsp?id=" + lotId : "lotProductModify.jsp?id=" + lotId;
                        %>
                        <tr>
                            <td class="dt-center"><%= count++ %></td>
                            <td class="dt-center"><%= category %></td>
                            <td class="dt-center"><%= lotNumber %></td>
                            <td class="name">
                                <a href="<%= modifyPage %>" class="item-link"><%= itemName %></a>
                            </td>
                            <td class="dt-right"><%= stockQty %></td>
                            <td class="dt-center"><%= updatedAtDisplay %></td>
                        </tr>
                        <% 
                                } 
                            } catch(Exception e) { 
                                e.printStackTrace(); 
                            } finally { 
                                if(rs != null) try { rs.close(); } catch(Exception e){} 
                                if(stmt != null) try { stmt.close(); } catch(Exception e){} 
                                if(conn != null) try { conn.close(); } catch(Exception e){} 
                            } 
                        %>
                    </tbody>
                </table>

                <!-- 엑셀 다운로드 전용 숨겨진 테이블 -->
                <table id="excelExportTable" style="display:none;">
                    <thead>
                        <tr>
                            <th>카테고리</th>
                            <th>Lot번호</th>
                            <th>원료/제품명</th>
                            <th>현재재고량</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try { 
                                Class.forName("org.mariadb.jdbc.Driver"); 
                                conn = DriverManager.getConnection(url, dbUser, dbPass);
                                stmt = conn.createStatement();
                                String sql = "SELECT '원료' AS category, item_name, lot_number, "
                                        + "CONCAT(stock_qty_kg, ' kg') AS stock_qty "
                                        + "FROM item_lots "
                                        + "UNION ALL "
                                        + "SELECT '제품' AS category, item_name, lot_number, "
                                        + "CONCAT(stock_qty, ' 개') AS stock_qty "
                                        + "FROM product_lots";
                                rs = stmt.executeQuery(sql);

                                while(rs.next()) { 
                                    String category = rs.getString("category");
                                    String itemName = rs.getString("item_name") != null ? rs.getString("item_name") : "";
                                    if(itemName.isEmpty()) continue;
                                    String lotNumber = rs.getString("lot_number") != null ? rs.getString("lot_number") : "";
                                    String stockQty = rs.getString("stock_qty") != null ? rs.getString("stock_qty") : "0";
                        %>
                        <tr>
                            <td><%= category %></td>
                            <td><%= lotNumber %></td>
                            <td><%= itemName %></td>
                            <td><%= stockQty %></td>
                        </tr>
                        <% 
                                } 
                            } catch(Exception e) { 
                                e.printStackTrace(); 
                            } finally { 
                                if(rs != null) try { rs.close(); } catch(Exception e){} 
                                if(stmt != null) try { stmt.close(); } catch(Exception e){} 
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
                                { width: "60px", targets: 0, className: "dt-center" },
                                { width: "100px", targets: 1, className: "dt-center" },
                                { width: "150px", targets: 2, className: "dt-center" },
                                { width: "150px", targets: 4, className: "dt-right" },
                                { width: "160px", targets: 5, className: "dt-center" },
                            ],
                            responsive: true,
                            language: {
                                emptyTable: "등록된 Lot 데이터가 없습니다.",
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

                        // 엑셀 다운로드 이벤트 (열 너비 지정 및 테두리 적용형 XML 포맷)
                        $(document).on('click', '#excelBtn', function () {
                            let excelXML = '<?xml version="1.0" encoding="UTF-8"?>';
                            excelXML += '<?mso-application progid="Excel.Sheet"?>';
                            excelXML += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"';
                            excelXML += ' xmlns:o="urn:schemas-microsoft-com:office:office"';
                            excelXML += ' xmlns:x="urn:schemas-microsoft-com:office:excel"';
                            excelXML += ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"';
                            excelXML += ' xmlns:html="http://www.w3.org/TR/REC-html40">';
                            
                            // 스타일 정의 (테두리 및 폰트 설정)
                            excelXML += '<Styles>';
                            excelXML += '<Style ss:ID="Default" ss:Name="Normal">';
                            excelXML += '<Alignment ss:Vertical="Center"/>';
                            excelXML += '<Borders>';
                            excelXML += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D3D3D3"/>';
                            excelXML += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D3D3D3"/>';
                            excelXML += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D3D3D3"/>';
                            excelXML += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D3D3D3"/>';
                            excelXML += '</Borders>';
                            excelXML += '<Font ss:FontName="맑은 고딕" ss:Size="10"/>';
                            excelXML += '</Style>';
                            
                            // 헤더 스타일
                            excelXML += '<Style ss:ID="HeaderStyle">';
                            excelXML += '<Alignment ss:Horizontal="Center" ss:Vertical="Center"/>';
                            excelXML += '<Borders>';
                            excelXML += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#000000"/>';
                            excelXML += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#000000"/>';
                            excelXML += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#000000"/>';
                            excelXML += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#000000"/>';
                            excelXML += '</Borders>';
                            excelXML += '<Interior ss:Color="#EAEAEA" ss:Pattern="Solid"/>';
                            excelXML += '<Font ss:FontName="맑은 고딕" ss:Size="10" ss:Bold="1"/>';
                            excelXML += '</Style>';
                            excelXML += '</Styles>';

                            excelXML += '<Worksheet ss:Name="Lot재고현황"><Table>';

                            // 각 열(Column)의 기본 너비 지정 (텍스트가 잘리지 않고 여유있게 표시되도록 설정)
                            excelXML += '<Column ss:Width="100"/>'; // 카테고리
                            excelXML += '<Column ss:Width="150"/>'; // Lot번호
                            excelXML += '<Column ss:Width="250"/>'; // 원료/제품명
                            excelXML += '<Column ss:Width="150"/>'; // 현재재고량

                            // 헤더 행 생성
                            excelXML += '<Row>';
                            $('#excelExportTable thead th').each(function () {
                                let thText = $(this).text().replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
                                excelXML += '<Cell ss:StyleID="HeaderStyle"><Data ss:Type="String">' + thText + '</Data></Cell>';
                            });
                            excelXML += '</Row>';

                            // 바디 행 생성
                            $('#excelExportTable tbody tr').each(function () {
                                let rowText = "";
                                let cellsXML = "";
                                
                                $(this).find('td').each(function () {
                                    let tdText = $(this).text().trim();
                                    rowText += tdText;
                                    let safeText = tdText.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
                                    cellsXML += '<Cell ss:StyleID="Default"><Data ss:Type="String">' + safeText + '</Data></Cell>';
                                });

                                if (rowText !== "") {
                                    excelXML += '<Row>' + cellsXML + '</Row>';
                                }
                            });

                            excelXML += '</Table></Worksheet></Workbook>';

                            let blob = new Blob([excelXML], { type: 'application/vnd.ms-excel;charset=utf-8;' });
                            let link = document.createElement('a');
                            link.href = URL.createObjectURL(blob);
                            link.download = 'Lot재고현황_' + new Date().toISOString().slice(0, 10) + '.xls';
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