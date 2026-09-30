<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. request_id 수신
    String requestIdStr = request.getParameter("request_id");
    if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다. (요청 ID 누락)'); location.href='../workOrderProgressList.jsp';</script>");
        return;
    }
    int requestId = 0;
    try {
        requestId = Integer.parseInt(requestIdStr.trim());
    } catch (NumberFormatException e) {
        out.println("<script>alert('유효하지 않은 요청 ID입니다.'); location.href='../workOrderProgressList.jsp';</script>");
        return;
    }

    // 2. 세션 로그인 사용자명 (작업자 기본값으로 사용)
    String loginUserName = (String) session.getAttribute("userName");
    if (loginUserName == null) loginUserName = "";

    // 3. DB 변수 선언
    String productName = "";
    Timestamp requestDate = null;

    String batchNo = "";
    String dueDate = "";       // yyyy-MM-dd (DB 원본)
    String mfgDate = "";       // yyyy-MM-dd (DB 원본)
    double actualQty = 0;      // 실제제조량 (kg)
    double productCapacity = 0;
    String capacityUnit = "";

    List<String[]> subRows = new ArrayList<String[]>(); // {item_name, subsidiary_type, out_qty}

    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPass = System.getenv("DB_PASSWORD");
    if (dbPass == null) dbPass = "1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        // 3-1. work_order_requests : 제품명, 지시일자(request_date)
        String reqSql = "SELECT product_name, request_date FROM work_order_requests WHERE request_id = ?";
        pstmt = conn.prepareStatement(reqSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            productName = rs.getString("product_name") != null ? rs.getString("product_name") : "";
            requestDate = rs.getTimestamp("request_date");
        } else {
            out.println("<script>alert('해당 제조요청 정보를 찾을 수 없습니다.'); location.href='../workOrderProgressList.jsp';</script>");
            return;
        }
        rs.close();
        pstmt.close();

        // 3-2. work_order_making : 제조번호, EXP, 제조일자, 실제제조량, 제품용량
        String mkSql = "SELECT batch_no, due_date, mfg_date, actual_qty, product_capacity, capacity_unit "
                     + "FROM work_order_making WHERE request_id = ?";
        pstmt = conn.prepareStatement(mkSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            batchNo = rs.getString("batch_no") != null ? rs.getString("batch_no") : "";
            dueDate = rs.getString("due_date") != null ? rs.getString("due_date") : "";
            mfgDate = rs.getString("mfg_date") != null ? rs.getString("mfg_date") : "";
            actualQty = rs.getDouble("actual_qty");
            productCapacity = rs.getObject("product_capacity") != null ? rs.getDouble("product_capacity") : 0;
            capacityUnit = rs.getString("capacity_unit") != null ? rs.getString("capacity_unit") : "";
        }
        rs.close();
        pstmt.close();

        // 3-3. work_order_subsidiary : 제조완료 단계(step4)에서 등록한 예상사용 부자재 목록
        String subSql = "SELECT item_name, subsidiary_type, out_qty FROM work_order_subsidiary WHERE request_id = ?";
        pstmt = conn.prepareStatement(subSql);
        pstmt.setInt(1, requestId);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            String iName = rs.getString("item_name") != null ? rs.getString("item_name") : "";
            String sType = rs.getString("subsidiary_type") != null ? rs.getString("subsidiary_type") : "";
            int oQty = rs.getInt("out_qty");
            subRows.add(new String[]{ iName, sType, String.valueOf(oQty) });
        }
        rs.close();
        pstmt.close();

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<!-- DB Error: " + e.getMessage() + " -->");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }

    // 4. 화면 표시용 가공
    SimpleDateFormat korDf = new SimpleDateFormat("yyyy년 MM월 dd일");

    String orderDateDisplay = (requestDate != null) ? korDf.format(requestDate) : "";
    String workDateDisplay = korDf.format(new Date()); // 작업일자 = 오늘(충진 작업을 등록하는 날짜)
    String workDateForInput = new SimpleDateFormat("yyyy-MM-dd").format(new Date());

    // EXP 표시용 (yyMMdd), due_date는 "yyyy-MM-dd" 문자열이므로 하이픈만 제거해 가공
    String expDisplay = "";
    if (dueDate != null && dueDate.length() == 10) {
        expDisplay = dueDate.substring(2, 4) + dueDate.substring(5, 7) + dueDate.substring(8, 10);
    }

    String capacityDisplay = "";
    if (productCapacity > 0) {
        String capNum = (productCapacity == Math.floor(productCapacity))
                ? String.valueOf((long) productCapacity) : String.valueOf(productCapacity);
        capacityDisplay = capNum + (capacityUnit != null ? capacityUnit : "");
    }
    String productDisplayName = productName + (capacityDisplay.isEmpty() ? "" : "(" + capacityDisplay + ")");

    java.text.DecimalFormat qtyDf = new java.text.DecimalFormat("#,##0.####");
    String actualQtyDisplay = (actualQty > 0) ? qtyDf.format(actualQty) : "";

    // 5. 부자재 표(tbody) 행 개수 = 등록된 부자재 + 미등록 대비 빈 행 4개
    int blankRowCount = 4;
    int totalRowCount = subRows.size() + blankRowCount;
%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
<div id="wrap">
    <jsp:include page="/app/include/Header.jsp" />
    <div id="container">
        <div class="content workOrderProgressFilling">
            <div class="title_set">
                <h5 class="page_tit">
                    <p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>진행현황</b><i><img src="/images/svg/location_arrow.svg"></i>충진중
                </h5>
            </div>
            <section class="radius">
                <form id="fillingForm" action="workOrderProgressFillingAction.jsp" method="post">
                    <input type="hidden" name="request_id" value="<%= requestId %>">
                    <input type="hidden" name="manufacture_date" value="<%= mfgDate %>">
                    <input type="hidden" name="expiration_date" value="<%= dueDate %>">

                    <h6 class="doc_tit">포장 지시 및 기록서</h6>
                    <fieldset class="head">
                        <ul>
                            <li>지시일자 : <%= orderDateDisplay %></li>
                            <li>작업일자 : <%= workDateDisplay %><input type="hidden" name="work_date" value="<%= workDateForInput %>"></li>
                        </ul>
                        <table>
                            <tr>
                                <th rowspan="2">결<br>재</th>
                                <th>담당</th>
                                <th>팀장</th>
                            </tr>
                            <tr>
                                <td class="box"><input type="text" placeholder="담당입력"></td>
                                <td class="box"><input type="text" placeholder="담당입력"></td>
                            </tr>
                        </table>
                    </fieldset>
                    <fieldset class="body">
                        <table>
                            <thead>
                                <tr>
                                    <th colspan="4">제품명</th>
                                    <th>제조번호<br>(LOT NO)</th>
                                    <th>지시수량<br>(ea)</th>
                                    <th>제조입고량<br>(kg)</th>
                                </tr>
                                <tr>
                                    <td colspan="4" class="name"><%= productDisplayName %></td>
                                    <td class="lot"><%= batchNo %><% if (!expDisplay.isEmpty()) { %><br>EXP<%= expDisplay %><% } %></td>
                                    <td><div class="unit"><input type="text" class="inputText" name="order_qty_ea" inputmode="decimal"><i>ea</i></div></td>
                                    <td><div class="unit"><input type="text" class="inputText" name="mfg_input_qty" inputmode="decimal" value="<%= actualQtyDisplay %>"><i>kg</i></div></td>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <th rowspan="2">작업내용</th>
                                    <th rowspan="2">설비명</th>
                                    <th colspan="3">포장재 투입 수량 (ea)</th>
                                    <th rowspan="2">작업자</th>
                                    <th rowspan="2">자재불량(ea)</th>
                                </tr>
                                <tr>
                                    <th colspan="2">포장재 명</th>
                                    <th>수량</th>
                                </tr>
<%
    // ── 부자재 데이터 행 (work_order_subsidiary 조회 결과) ──
    for (int i = 0; i < subRows.size(); i++) {
        String iName = subRows.get(i)[0];
        String sType = subRows.get(i)[1];
        String oQty = subRows.get(i)[2];
        String materialLabel = iName + (sType != null && !sType.trim().isEmpty() ? "(" + sType.trim() + ")" : "");
%>
                                <tr>
<% if (i == 0) { %>
                                    <td rowspan="<%= totalRowCount %>"><input type="text" class="inputText" value="충진" placeholder="작업내용 입력"></td>
                                    <td rowspan="<%= totalRowCount %>"><input type="text" class="inputText" value="충진기" placeholder="설비명 입력"></td>
<% } %>
                                    <td colspan="2"><input type="text" name="item_name[]" class="inputText" value="<%= materialLabel %>" placeholder="포장재명 입력"></td>
                                    <td><div class="unit"><input type="text" name="out_qty[]" class="inputText" inputmode="decimal" value="<%= oQty %>"><i>ea</i></div></td>
                                    <td><input type="text" class="inputText" value="<%= loginUserName %>" placeholder="작업자 입력"></td>
                                    <td><div class="unit"><input type="text" class="inputText" inputmode="decimal"><i>ea</i></div></td>
                                </tr>
<%
    }

    // ── 미등록 부자재 대비 빈 행 (기본 4개) ──
    for (int i = 0; i < blankRowCount; i++) {
        boolean isFirstOverall = (subRows.size() == 0 && i == 0);
%>
                                <tr>
<% if (isFirstOverall) { %>
                                    <td rowspan="<%= totalRowCount %>"><input type="text" class="inputText" value="충진" placeholder="작업내용 입력"></td>
                                    <td rowspan="<%= totalRowCount %>"><input type="text" class="inputText" value="충진기" placeholder="설비명 입력"></td>
<% } %>
                                    <td colspan="2"><input type="text" name="item_name[]" class="inputText" placeholder="포장재명 입력"></td>
                                    <td><div class="unit"><input type="text" name="out_qty[]" class="inputText" inputmode="decimal"><i>ea</i></div></td>
                                    <td><input type="text" class="inputText" placeholder="작업자 입력"></td>
                                    <td><div class="unit"><input type="text" class="inputText" inputmode="decimal"><i>ea</i></div></td>
                                </tr>
<%
    }
%>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <th rowspan="6">작업 후<br>내부감사</th>
                                    <th rowspan="2" colspan="3">항목</th>
                                    <th colspan="2">확인</th>
                                    <th rowspan="2">비고</th>
                                </tr>
                                <tr>
                                    <th>적합/부적합</th>
                                    <th>부적합(내용)</th>
                                </tr>
                                <tr>
                                    <td colspan="3" class="item">작업이 끝난 완제품의 인수인계 여부</td>
                                    <td>
                                        <div class="radioGroup">
                                            <label class="radioButton"><input type="radio" name="item1" class="judge-radio" data-reason-target="#item1_reason" value="적합" checked><i class="icon"></i><span>적합</span></label>
                                            <label class="radioButton"><input type="radio" name="item1" class="judge-radio" data-reason-target="#item1_reason" value="부적합"><i class="icon"></i><span>부적합</span></label>
                                        </div>
                                    </td>
                                    <td><input type="text" id="item1_reason" name="item1_reason" class="inputText" disabled="disabled" placeholder="내용입력"></td>
                                    <td><input type="text" class="inputText" placeholder="비고입력"></td>
                                </tr>
                                <tr>
                                    <td colspan="3" class="item">부적합 제품의 별도 보관 여부</td>
                                    <td>
                                        <div class="radioGroup">
                                            <label class="radioButton"><input type="radio" name="item2" class="judge-radio" data-reason-target="#item2_reason" value="적합" checked><i class="icon"></i><span>적합</span></label>
                                            <label class="radioButton"><input type="radio" name="item2" class="judge-radio" data-reason-target="#item2_reason" value="부적합"><i class="icon"></i><span>부적합</span></label>
                                        </div>
                                    </td>
                                    <td><input type="text" id="item2_reason" name="item2_reason" class="inputText" disabled="disabled" placeholder="내용입력"></td>
                                    <td><input type="text" class="inputText" placeholder="비고입력"></td>
                                </tr>
                                <tr>
                                    <td colspan="3" class="item">사용된 부자재의 제품 사양과의 일치 여부</td>
                                    <td>
                                        <div class="radioGroup">
                                            <label class="radioButton"><input type="radio" name="item3" class="judge-radio" data-reason-target="#item3_reason" value="적합" checked><i class="icon"></i><span>적합</span></label>
                                            <label class="radioButton"><input type="radio" name="item3" class="judge-radio" data-reason-target="#item3_reason" value="부적합"><i class="icon"></i><span>부적합</span></label>
                                        </div>
                                    </td>
                                    <td><input type="text" id="item3_reason" name="item3_reason" class="inputText" disabled="disabled" placeholder="내용입력"></td>
                                    <td><input type="text" class="inputText" placeholder="비고입력"></td>
                                </tr>
                                <tr>
                                    <td colspan="3" class="item">지시 수량과 생산수량의 일치 여부</td>
                                    <td>
                                        <div class="radioGroup">
                                            <label class="radioButton"><input type="radio" name="item4" class="judge-radio" data-reason-target="#item4_reason" value="적합" checked><i class="icon"></i><span>적합</span></label>
                                            <label class="radioButton"><input type="radio" name="item4" class="judge-radio" data-reason-target="#item4_reason" value="부적합"><i class="icon"></i><span>부적합</span></label>
                                        </div>
                                    </td>
                                    <td><input type="text" id="item4_reason" name="item4_reason" class="inputText" disabled="disabled" placeholder="내용입력"></td>
                                    <td><input type="text" class="inputText" placeholder="비고입력"></td>
                                </tr>
                                <tr>
                                    <th rowspan="6">생산현황</th>
                                    <th>작업 시간</th>
                                    <td><div class="unit"><input type="text" class="inputText" inputmode="decimal"><i>hr</i></div></td>
                                    <th rowspan="6">수율분석</th>
                                    <th>제조량</th>
                                    <td colspan="2"><div class="unit"><input type="text" class="inputText" inputmode="decimal" value="<%= actualQtyDisplay %>"><i>kg</i></div></td>
                                </tr>
                                <tr>
                                    <th>작업 인원</th>
                                    <td><div class="unit"><input type="text" class="inputText" inputmode="decimal"><i>명</i></div></td>
                                    <th>생산량</th>
                                    <td colspan="2"><div class="unit"><input type="text" class="inputText" inputmode="decimal"><i>kg</i></div></td>
                                </tr>
                                <tr>
                                    <th>지시 수량</th>
                                    <td><div class="unit"><input type="text" class="inputText" inputmode="decimal"><i>ea</i></div></td>
                                    <th rowspan="2">수율</th>
                                    <td colspan="2" rowspan="2">
                                        <div class="unit"><input type="text" class="inputText" inputmode="decimal"><i>%</i></div>
                                        <p class="ex">(생산량/제조량*100)</p>
                                    </td>
                                </tr>
                                <tr>
                                    <th>생산 수량</th>
                                    <td><div class="unit"><input type="text" id="production_qty" name="production_qty" class="inputText" inputmode="decimal" required><i>ea</i></div></td>
                                </tr>
                                <tr>
                                    <th>폐기 수량</th>
                                    <td><div class="unit"><input type="text" class="inputText" inputmode="decimal"><i>ea</i></div></td>
                                    <th rowspan="2">불량율</th>
                                    <td colspan="2" rowspan="2">
                                        <div class="unit"><input type="text" class="inputText" inputmode="decimal"><i>%</i></div>
                                        <p class="ex">(폐기수량/생산수량*100)</p>
                                    </td>
                                </tr>
                                <tr>
                                    <th>출고 수량</th>
                                    <td><div class="unit"><input type="text" class="inputText" inputmode="decimal"><i>ea</i></div></td>
                                </tr>
                                <tr class="last">
                                    <th>작성자</th>
                                    <td colspan="2"><input type="text" class="inputText" value="<%= loginUserName %>" placeholder="작성자 입력"></td>
                                    <th colspan="2">판정</th>
                                    <td colspan="2">
                                        <div class="radioGroup">
                                            <label class="radioButton"><input type="radio" name="verdict" checked><i class="icon"></i><span>적합</span></label>
                                            <label class="radioButton"><input type="radio" name="verdict"><i class="icon"></i><span>부적합</span></label>
                                        </div>
                                    </td>
                                </tr>
                            </tfoot>
                        </table>
                    </fieldset>
                    <div class="bottom_btns">
                        <button type="button" class="Button bgGray" data-width="180" onclick="location.href='../workOrderProgressList.jsp';">목록</button>
                        <button type="submit" id="btnComplete" class="Button bgBlue" data-width="180">충진완료</button>
                    </div>
                </form>
            </section>
        </div>
    </div>
</div>

<script>
    $(document).ready(function () {
        // ── 숫자 입력 콤마 포맷 (inputmode="decimal") ──
        function formatWithComma(str) {
            if (!str) return '';
            const parts = str.split('.');
            parts[0] = parts[0].replace(/,/g, '').replace(/\B(?=(\d{3})+(?!\d))/g, ',');
            return parts.join('.');
        }
        $(document).on('input', 'input[inputmode="decimal"]', function () {
            let value = $(this).val().replace(/[^0-9.]/g, '');
            const parts = value.split('.');
            if (parts.length > 2) value = parts[0] + '.' + parts.slice(1).join('');
            $(this).val(formatWithComma(value));
        });

        // ── 요구사항 5: 항목1~4 적합/부적합 라디오 → 내용 input 활성/비활성 ──
        $(document).on('change', '.judge-radio', function () {
            let $this = $(this);
            let $reasonInput = $($this.data('reason-target'));
            if ($this.val() === '부적합') {
                $reasonInput.prop('disabled', false);
            } else {
                $reasonInput.prop('disabled', true).val('');
            }
        });

        // ── 요구사항 6: 충진완료 제출 전 검증 ──
        $('#fillingForm').on('submit', function (e) {
            let qtyRaw = $('#production_qty').val().replace(/,/g, '');
            let qty = parseInt(qtyRaw, 10) || 0;

            if (qty <= 0) {
                alert('생산 수량을 입력해 주세요.');
                e.preventDefault();
                $('#production_qty').focus();
                return false;
            }

            if (!confirm('충진을 완료하고 제품 재고에 반영하시겠습니까?')) {
                e.preventDefault();
                return false;
            }

            // 콤마 제거 후 제출 (실제 폼 전송은 그대로 진행됨)
            $(this).find('input[inputmode="decimal"]').each(function () {
                let raw = $(this).val().replace(/,/g, '');
                $(this).val(raw);
            });
        });
    });
</script>
<jsp:include page="/app/include/FooterDocType.jsp" />