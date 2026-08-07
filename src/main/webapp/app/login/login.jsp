<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 저장된 쿠키에서 아이디 가져오기
    String savedId = "";
    boolean isRemembered = false;

    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("rememberedId".equals(cookie.getName())) {
                savedId = cookie.getValue();
                isRemembered = true;
                break;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
    <link rel="shortcut icon" href="https://seoholab.com/favicon.ico">
    <title>서호랩::재고관리 시스템</title>
    <link rel="stylesheet" href="/css/style.css" />
    <link rel="stylesheet" href="/css/module/swiper-bundle.min.css" />
    <script src="/scripts/module/jquery-3.7.1.min.js"></script>
    <script src="/scripts/module/swiper-bundle.min.js"></script>
    <script src="/scripts/ui.js"></script>
</head>
<body>
    <div id="wrap">
        <div id="container" class="login">
            <form action="loginProcess.jsp" method="post">
                <h1><img src="/images/logo/logo-basic.svg"></h1>
                <fieldset class="id-pw">
                    <h2>생산 재고관리 시스템</h2>
                    <input type="text" class="enter" placeholder="ID" name="user_id" value="<%= savedId %>" required>
                    <input type="password" class="enter" placeholder="PASSWORD" name="user_pw">
                    <div class="id_save">
                        <label class="checkBox"><input type="checkbox" id="remember_me" name="remember_me" value="true" <%= isRemembered ? "checked" : "" %>><i class="icon"></i> ID save</label>
                    </div>
                    <button type="submit">로그인</button>
                </fieldset>
            </form>
        </div>
    </div>
</body>
</html>