<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Inventory.ERP - Home</title>
    <style>
        body {
            font-family: 'Malgun Gothic', Arial, sans-serif;
            background-color: #f4f6f9;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .card {
            background: #ffffff;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            text-align: center;
            max-width: 450px;
            width: 100%;
        }
        h1 {
            color: #2c3e50;
            font-size: 24px;
            margin-bottom: 10px;
        }
        p {
            color: #7f8c8d;
            font-size: 14px;
            line-height: 1.6;
        }
        .status {
            display: inline-block;
            margin-top: 15px;
            padding: 6px 12px;
            background-color: #e8f5e9;
            color: #2e7d32;
            border-radius: 20px;
            font-weight: bold;
            font-size: 13px;
        }
        .server-info {
            margin-top: 20px;
            font-size: 12px;
            color: #bdc3c7;
            border-top: 1px solid #ecf0f1;
            padding-top: 15px;
        }
    </style>
</head>
<body>

    <div class="card">
        <h1>Inventory.ERP</h1>
        <p>Dynamic Web Project 구동 테스트 페이지입니다.</p>
        
        <div class="status">
            ✓ Tomcat Server Connected
        </div>

        <div class="server-info">
            서버 현재 시간: <%= new java.text.SimpleDateFormat("yyyy-MM-DD HH:mm:ss").format(new java.util.Date()) %>
        </div>
    </div>

</body>
</html>