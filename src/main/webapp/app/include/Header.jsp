<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
%>
<script>
    function fnLogout() {
        // confirm 창을 띄우고 사용자가 '확인'을 누르면 true, '취소'를 누르면 false가 리턴됩니다.
        if (confirm("정말 로그아웃 하시겠습니까?")) {
            // '확인'을 눌렀을 때 실행할 코드
            location.href = "/app/login/logoutProcess.jsp";
        }
    }
</script>
<header>
    <h1 class="logo"><i class="mo_menu"><img src="/images/svg/mobile_menu.svg"></i><a href="#"><img src="/images/logo/logo-basic.svg"></a></h1>
    <div class="menu">
        <div class="mobile_ctrl"><img src="/images/logo/logo-basic.svg"><a href="#" class="close"><img src="/images/svg/mobile_menu_close.svg"></a></div>
        <div class="user_wrap">
            <p class="user"><%= userName %>님</p>
            <button type="button" onclick="fnLogout();">로그아웃</button>
        </div>
        <ul class="gnb">
            <li class="no_depth on"><a href="#"><img src="/images/svg/icon_calendar.svg">근태내역</a></li>
            <li class="has_depth">
                <p><img src="/images/svg/icon_image.svg">이미지 보안</p>
                <div class="depth">
                    <div>
                        <a href="#">이미지 승인 관리</a>
                        <a href="#">이미지 결재 관리</a>
                    </div>
                </div>
            </li>
            <li class="has_depth">
                <p><img src="/images/svg/icon_setup.svg">환경설정</p>
                <div class="depth">
                    <div>
                        <a href="#">결재 담당자 관리</a>
                        <a href="#">운영 담당자 관리</a>
                    </div>
                </div>
            </li>
        </ul>
    </div>
</header>