<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<jsp:include page="/app/include/HeaderDocType.jsp" />
<script>
    $(function () {
        // --- 1. 직원 등록 다이얼로그 설정 ---
        var dialog, form,
            name = $("#name"),
            memID = $("#memID"),
            position = $("#position"),
            temPassword = $("#temPassword"),
            allFields = $([]).add(name).add(memID).add(position).add(temPassword),
            tips = $(".validateTips");

        function updateTips(t) {
            tips.text(t).addClass("ui-state-highlight");
            setTimeout(function () {
                tips.removeClass("ui-state-highlight", 1500);
            }, 500);
        }

        function checkLength(o, n, min, max) {
            if (o.val().length > max || o.val().length < min) {
                o.addClass("ui-state-error");
                updateTips("Length of " + n + " must be between " + min + " and " + max + ".");
                return false;
            } else {
                return true;
            }
        }

        function addUser() {
            var valid = true;
            allFields.removeClass("ui-state-error");

            valid = valid && checkLength(name, "username", 2, 16);
            valid = valid && checkLength(memID, "memID", 3, 50);
            valid = valid && checkLength(position, "position", 1, 30);
            valid = valid && checkLength(temPassword, "temPassword", 4, 20);

            if (valid) {
                $.ajax({
                    url: "memberRegistAction.jsp",
                    type: "POST",
                    data: {
                        user_id: memID.val(),
                        user_name: name.val(),
                        position: position.val(),
                        user_pw: temPassword.val()
                    },
                    success: function (response) {
                        response = response.trim();
                        if (response === "success") {
                            alert("직원이 등록되었습니다.");
                            location.reload();
                        } else if (response === "fail:empty") {
                            alert("모든 값을 입력해 주세요.");
                        } else {
                            alert("등록 실패 (중복된 ID이거나 오류가 발생했습니다).");
                        }
                    },
                    error: function () {
                        alert("서버 통신 중 오류가 발생했습니다.");
                    }
                });
                dialog.dialog("close");
            }
            return valid;
        }

        dialog = $("#dialog-form").dialog({
            autoOpen: false,
            width: 350,
            modal: true,
            buttons: {
                "등록": addUser,
                "취소": function () {
                    dialog.dialog("close");
                }
            },
            close: function () {
                form[0].reset();
                allFields.removeClass("ui-state-error");
            }
        });

        form = dialog.find("form").on("submit", function (event) {
            event.preventDefault();
            addUser();
        });

        $("#create-user").button().on("click", function () {
            dialog.dialog("open");
        });

        // --- 2. 직급 수정 다이얼로그 설정 ---
        var updateDialog, updateForm,
            editUserId = $("#editUserId"),
            editUserName = $("#editUserName"),
            editPosition = $("#editPosition");

        function updatePositionAction() {
            if (editPosition.val().trim() === "") {
                alert("변경할 직급을 입력해 주세요.");
                return;
            }

            $.ajax({
                url: "memberUpdateAction.jsp",
                type: "POST",
                data: {
                    user_id: editUserId.val(),
                    position: editPosition.val()
                },
                success: function (response) {
                    response = response.trim();
                    if (response === "success") {
                        alert("직급이 수정되었습니다.");
                        location.reload();
                    } else {
                        alert("직급 수정에 실패했습니다.");
                    }
                },
                error: function () {
                    alert("서버 통신 중 오류가 발생했습니다.");
                }
            });
            updateDialog.dialog("close");
        }

        updateDialog = $("#dialog-update-form").dialog({
            autoOpen: false,
            width: 350,
            modal: true,
            buttons: {
                "수정": updatePositionAction,
                "취소": function () {
                    updateDialog.dialog("close");
                }
            }
        });

        updateForm = updateDialog.find("form").on("submit", function (event) {
            event.preventDefault();
            updatePositionAction();
        });

        // 수정 버튼 클릭 시 팝업 열기 및 데이터 바인딩
        $(document).on("click", ".update-btn", function () {
            var userId = $(this).data("userid");
            var userName = $(this).data("username");
            var userPos = $(this).data("position");

            editUserId.val(userId);
            editUserName.text(userName);
            editPosition.val(userPos);

            updateDialog.dialog("open");
        });

        // --- 3. 삭제 버튼 이벤트 위임 ---
        $(document).on("click", ".delete-btn", function () {
            var userId = $(this).data("userid");
            var userName = $(this).data("username");
            if (confirm(userName + "님의 계정을 삭제하시겠습니까?")) {
                $.ajax({
                    url: "memberDeleteAction.jsp",
                    type: "POST",
                    data: { user_id: userId },
                    success: function (response) {
                        response = response.trim();
                        if (response === "success") {
                            alert("계정이 삭제되었습니다.");
                            location.reload();
                        } else {
                            alert("삭제에 실패했습니다.");
                        }
                    },
                    error: function () {
                        alert("서버 통신 중 오류가 발생했습니다.");
                    }
                });
            }
        });
    });
</script>
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content member">
                <div class="title_set">
                    <h5 class="page_tit"><p>계정관리</p><i><img src="/images/svg/location_arrow.svg"></i><b>직원관리</b></h5>
                </div>
                <div class="top_btn"><button type="button" id="create-user" class="Button bgBlue">직원추가</button></div>
                <section class="radius">
                    <!-- 직원 등록 다이얼로그 폼 -->
                    <div id="dialog-form" class="dialog-form" style="display:none;" title="직원 등록">
                        <form class="memberRegist">
                            <ul>
                                <li>
                                    <label for="name">이름</label>
                                    <input type="text" name="name" id="name" class="inputText" placeholder="이름 입력">
                                </li>
                                <li>
                                    <label for="memID">ID</label>
                                    <input type="text" name="memID" id="memID" class="inputText" placeholder="직원 ID 입력">
                                </li>
                                <li>
                                    <label for="position">직급</label>
                                    <input type="text" name="position" id="position" class="inputText" placeholder="직급 입력">
                                </li>
                                <li>
                                    <label for="temPassword">임시암호</label>
                                    <input type="password" name="temPassword" id="temPassword" class="inputText" placeholder="임시암호 입력">
                                </li>
                                <input type="submit" tabindex="-1" style="position:absolute; top:-1000px">
                            </ul>
                        </form>
                    </div>

                    <!-- 직급 수정 다이얼로그 폼 (신규 추가) -->
                    <div id="dialog-update-form" class="dialog-form" style="display:none;" title="직급 수정">
                        <form class="memberRegist">
                            <ul>
                                <li>
                                    <label>이름</label>
                                    <span id="editUserName" class="edit_user_name"></span>
                                    <input type="hidden" id="editUserId">
                                </li>
                                <li>
                                    <label for="editPosition">직급</label>
                                    <input type="text" name="editPosition" id="editPosition" class="inputText" placeholder="직급 입력">
                                </li>
                                <input type="submit" tabindex="-1" style="position:absolute; top:-1000px">
                            </ul>
                        </form>
                    </div>

                    <div class="works_grid">
                        <table id="users">
                            <thead>
                                <tr>
                                    <th>직급</th>
                                    <th>이름</th>
                                    <th>ID</th>
                                    <th>수정/삭제</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
                                    String dbUser = "root";
                                    String dbPass = System.getenv("DB_PASSWORD");
                                    if (dbPass == null) dbPass = "1234";
    
                                    Connection conn = null;
                                    PreparedStatement pstmt = null;
                                    ResultSet rs = null;
    
                                    try {
                                        Class.forName("org.mariadb.jdbc.Driver");
                                        conn = DriverManager.getConnection(url, dbUser, dbPass);
                                        String sql = "SELECT user_id, user_name, position FROM users ORDER BY created_at DESC";
                                        pstmt = conn.prepareStatement(sql);
                                        rs = pstmt.executeQuery();
    
                                        boolean hasData = false;
                                        while (rs.next()) {
                                            hasData = true;
                                            String uId = rs.getString("user_id");
                                            String uName = rs.getString("user_name");
                                            String uPos = rs.getString("position");
                                            if (uPos == null) uPos = "-";
                                %>
                                <tr>
                                    <td data-roll="직급"><%= uPos %></td>
                                    <td data-roll="이름"><%= uName %></td>
                                    <td data-roll="ID"><%= uId %></td>
                                    <td>
                                        <!-- 수정 버튼에 data 속성으로 기존 정보 전달 -->
                                        <button type="button" class="update-btn" data-userid="<%= uId %>" data-username="<%= uName %>" data-position="<%= uPos.equals("-") ? "" : uPos %>">수정</button>
                                        <button type="button" class="delete-btn" data-userid="<%= uId %>" data-username="<%= uName %>">삭제</button>
                                    </td>
                                </tr>
                                <%
                                        }
                                        if (!hasData) {
                                %>
                                <tr>
                                    <td colspan="4" style="text-align:center;">등록된 직원이 없습니다.</td>
                                </tr>
                                <%
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                %>
                                <tr>
                                    <td colspan="4" style="text-align:center; color:red;">데이터를 불러오는 중 오류가 발생했습니다.</td>
                                </tr>
                                <%
                                    } finally {
                                        if (rs != null) try { rs.close(); } catch(Exception e){}
                                        if (pstmt != null) try { pstmt.close(); } catch(Exception e){}
                                        if (conn != null) try { conn.close(); } catch(Exception e){}
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </section>
            </div>
        </div>
    </div>
<jsp:include page="/app/include/FooterDocType.jsp" />