<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
%>
<script>
    function fnLogout() {
        if (confirm("정말 로그아웃 하시겠습니까?")) {
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
            <li class="no_depth"><a href="#"><img src="/images/svg/flask-solid-full.svg">사용등록</a></li>
            <li class="no_depth"><a href="#"><img src="/images/svg/truck-arrow-right-solid-full.svg">출고등록</a></li>
            <li class="no_depth"><a href="#"><img src="/images/svg/dolly-solid-full.svg">입고등록</a></li>
            <li class="has_depth">
                <p><img src="/images/svg/droplet-solid-full.svg">원료</p>
                <div class="depth">
                    <div>
                        <a href="/app/rawMaterial/rawMaterialStockList.jsp">재고</a>
                        <a href="/app/rawMaterial/rawMaterialRegist.jsp">신규등록</a>
                    </div>
                </div>
            </li>
            <li class="has_depth">
                <p><img src="/images/svg/boxes-packing-solid-full.svg">완제품</p>
                <div class="depth">
                    <div>
                        <a href="#">재고</a>
                        <a href="#">신규등록</a>
                    </div>
                </div>
            </li>
            <li class="has_depth">
                <p><img src="/images/svg/bottle-droplet-solid-full.svg">부자재</p>
                <div class="depth">
                    <div>
                        <a href="#">재고</a>
                        <a href="#">신규등록</a>
                    </div>
                </div>
            </li>
        </ul>
    </div>
</header>