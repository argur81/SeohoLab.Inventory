<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. 사용자가 입력한 아이디와 비밀번호 가져오기
    request.setCharacterEncoding("UTF-8");
    String inputId = request.getParameter("user_id");
    String inputPw = request.getParameter("user_pw");

    // 2. 데이터베이스 연결 정보 설정
    String url = "jdbc:mariadb://svc.sel3.cloudtype.app:32170/seoholabdb";
    String dbUser = "root";       
    String dbPass = System.getenv("DB_PASSWORD"); 
    if (dbPass == null) {
        dbPass = "1234"; // 로컬 기본 비밀번호
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // 3. MariaDB 드라이버 로드 및 DB 연결
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        // 4. 입력한 아이디와 일치하는 사용자의 비밀번호와 이름(user_name) 조회
        String sql = "SELECT user_pw, user_name FROM users WHERE user_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, inputId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            String dbPw = rs.getString("user_pw");
            String userName = rs.getString("user_name"); // DB의 user_name 컬럼 값 읽기

            // 5. 비밀번호 일치 여부 확인
            if (dbPw.equals(inputPw)) {
                // 로그인 성공 시 세션에 아이디와 이름 저장
                session.setAttribute("userId", inputId);
                session.setAttribute("userName", userName);
%>
                <script>
                    location.href = "/app/home/main.jsp"; // 로그인 후 이동할 페이지
                </script>
<%
            } else {
                // 비밀번호 불일치
%>
                <script>
                    alert("비밀번호를 확인하세요.");
                    history.back();
                </script>
<%
            }
        } else {
            // 아이디 존재하지 않음
%>
            <script>
                alert("회원님의 계정을 찾을 수 없습니다.");
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
        // 6. 자원 해제
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>