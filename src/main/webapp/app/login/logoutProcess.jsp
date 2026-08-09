<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 1. 세션 전체 무효화 (로그아웃 처리)
    session.invalidate();

    // 2. 브라우저 캐시 방지 헤더 설정
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>
<script>
    location.href = "/app/login/login.jsp"; 
</script>