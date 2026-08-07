<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. 사용자가 입력한 아이디와 비밀번호 가져오기
    request.setCharacterEncoding("UTF-8");
    String inputId = request.getParameter("user_id");
    String inputPw = request.getParameter("user_pw");

    // 2. 데이터베이스 연결 정보 설정
    // (Cloudtype 등에 배포된 DB 주소, 포트, DB이름, 계정 정보를 입력하세요)
    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";       // 본인의 DB 접속 아이디 (예: root)
    String dbPass = System.getenv("DB_PASSWORD"); 
    if (dbPass == null) {
        dbPass = "1234"; 
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // 3. MariaDB 드라이버 로드 및 DB 연결
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        // 4. 입력한 아이디와 일치하는 사용자 조회 쿼리
        String sql = "SELECT user_pw FROM users WHERE user_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, inputId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            String dbPw = rs.getString("user_pw");

            // 5. 비밀번호 일치 여부 확인
            if (dbPw.equals(inputPw)) {
                // 로그인 성공 시 세션에 아이디 저장 등 처리
                session.setAttribute("userId", inputId);
%>
                <script>
                    alert("로그인 성공! 환영합니다, <%= inputId %>님.");
                    location.href = "main.jsp"; // 로그인 후 이동할 페이지
                </script>
<%
            } else {
                // 비밀번호 틀림
%>
                <script>
                    alert("비밀번호가 일치하지 않습니다.");
                    history.back();
                </script>
<%
            }
        } else {
            // 아이디 존재하지 않음
%>
            <script>
                alert("존재하지 않는 아이디입니다.");
                history.back();
            </script>
<%
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
        <script>
            alert("데이터베이스 연동 중 오류가 발생했습니다.");
            history.back();
        </script>
<%
    } finally {
        // 6. 사용한 자원 닫기 (메모리 누수 방지)
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>