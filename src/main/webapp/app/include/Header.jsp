<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String currentURI = request.getRequestURI();
    if (userId == null || userId.trim().isEmpty()) {
        if (!currentURI.endsWith("login.jsp") && !currentURI.endsWith("loginAction.jsp")) {
            out.println("<script>");
            out.println("alert('로그인이 필요한 서비스입니다.');");
            out.println("location.href='/app/login/login.jsp';");
            out.println("</script>");
            return; // 👈 리다이렉트 후 이후 스크립트/JSP가 실행되지 않도록 중단
        }
    }
%>
<script>
    window.addEventListener('pageshow', function (event) {
        // event.persisted가 true이면 뒤로가기로 페이지가 캐시에서 복원된 상태임
        if (event.persisted || (window.performance && window.performance.navigation.type === 2)) {
            // 페이지를 강제로 새로고침하여 서버 세션 체크(JSP)를 다시 타게 만듦
            window.location.reload();
        }
    });
</script>
<header>
    <h1 class="logo"><i class="mo_menu"><img src="/images/svg/mobile_menu.svg"></i><a href="/app/home/main.jsp"><img src="/images/logo/logo-basic.svg"></a></h1>
    <div class="menu">
        <div class="mobile_ctrl"><img src="/images/logo/logo-basic.svg"><a href="#" class="close"><img src="/images/svg/mobile_menu_close.svg"></a></div>
        <div class="user_wrap">
            <p class="user"><%= userName %>님</p>
            <button type="button" onclick="location.href='/app/login/logoutProcess.jsp'">로그아웃</button>
        </div>
        <ul class="gnb">
            <li class="has_depth regist">
                <p><img src="/images/svg/flask-solid-full.svg">사용·출고·입고</p>
                <div class="depth">
                    <div>
                        <a href="/app/totalRegist/usedRegist.jsp" class="used">사용등록</a>
                        <a href="/app/totalRegist/releaseRegist.jsp" class="release">출고등록</a>
                        <a href="/app/totalRegist/receivingRegist.jsp" class="receiving">입고등록</a>
                    </div>
                </div>
            </li>
            <li class="has_depth stock">
                <p><img src="/images/svg/boxes-packing-solid-full.svg">재고현황</p>
                <div class="depth">
                    <div>
                        <a href="/app/rawMaterial/rawMaterialStockList.jsp" class="raw">원료</a>
                        <a href="/app/product/productStockList.jsp" class="product">제품</a>
                        <a href="/app/subsidiary/subsidiaryStockList.jsp" class="subsidiary">부자재</a>
                    </div>
                </div>
            </li>
            <li class="has_depth new">
                <p><img src="/images/svg/plus-solid-full.svg">신규등록</p>
                <div class="depth">
                    <div>
                        <a href="/app/rawMaterial/rawMaterialRegist.jsp" class="raw">원료</a>
                        <a href="/app/product/productRegist.jsp" class="product">제품</a>
                        <a href="/app/subsidiary/subsidiaryRegist.jsp" class="subsidiary">부자재</a>
                    </div>
                </div>
            </li>
            <li class="has_depth new">
                <p><img src="/images/svg/user-gear-solid-full.svg">계정관리</p>
                <div class="depth">
                    <div>
                        <a href="/app/account/myPage.jsp" class="myPage">나의정보</a>
                        <a href="/app/account/authority.jsp" class="authority">권한관리</a>
                        <a href="/app/account/member.jsp" class="member">직원관리</a>
                    </div>
                </div>
            </li>
        </ul>
    </div>
</header>