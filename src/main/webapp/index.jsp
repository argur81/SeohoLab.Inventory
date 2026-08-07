<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 1. 현재 세션에서 userId 정보를 가져옴
    String userId = (String) session.getAttribute("userId");

    // 2. 로그인 상태인지 확인
    if (userId != null) {
        // 로그인 상태라면 main.jsp로 이동
        response.sendRedirect("/app/home/main.jsp");
    } else {
        // 로그아웃(세션 없음) 상태라면 login.jsp로 이동
        response.sendRedirect("/app/login/login.jsp");
    }
%>