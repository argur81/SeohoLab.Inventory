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
            <li class="no_depth"><a href="/app/totalRegist/usedRegist.jsp"><img src="/images/svg/flask-solid-full.svg">사용등록</a></li>
            <li class="no_depth"><a href="/app/totalRegist/releaseRegist.jsp"><img src="/images/svg/truck-arrow-right-solid-full.svg">출고등록</a></li>
            <li class="no_depth"><a href="/app/totalRegist/receivingRegist.jsp"><img src="/images/svg/dolly-solid-full.svg">입고등록</a></li>
            <li class="has_depth raw">
                <p><img src="/images/svg/droplet-solid-full.svg">원료</p>
                <div class="depth">
                    <div>
                        <a href="/app/rawMaterial/rawMaterialStockList.jsp">재고현황</a>
                        <a href="/app/rawMaterial/rawMaterialRegist.jsp">신규등록</a>
                    </div>
                </div>
            </li>
            <li class="has_depth product">
                <p><img src="/images/svg/boxes-packing-solid-full.svg">제품</p>
                <div class="depth">
                    <div>
                        <a href="/app/product/productStockList.jsp">재고현황</a>
                        <a href="/app/product/productRegist.jsp">신규등록</a>
                    </div>
                </div>
            </li>
            <li class="has_depth subsidiary">
                <p><img src="/images/svg/bottle-droplet-solid-full.svg">부자재</p>
                <div class="depth">
                    <div>
                        <a href="/app/subsidiary/subsidiaryStockList.jsp">재고현황</a>
                        <a href="/app/subsidiary/subsidiaryRegist.jsp">신규등록</a>
                    </div>
                </div>
            </li>
        </ul>
    </div>
</header>