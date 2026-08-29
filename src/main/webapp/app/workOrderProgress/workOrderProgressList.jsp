<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<style>
    /* [Style] 로딩 오버레이 디자인 */
    #loadingOverlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(255, 255, 255, 1);
        z-index: 9999;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }

    /* [Style] 로딩 스피너 애니메이션 */
    .spinner {
        width: 50px;
        height: 50px;
        border: 5px solid #f3f3f3;
        border-top: 5px solid #3498db;
        border-radius: 50%;
        animation: spin 1s linear infinite;
    }

    .loading_text {
        margin-top: 15px;
        font-weight: bold;
        color: #333;
        font-size: 14px;
    }

    @keyframes spin {
        0% {
            transform: rotate(0deg);
        }

        100% {
            transform: rotate(360deg);
        }
    }
</style>
<jsp:include page="/app/include/HeaderDocType.jsp" />
<!-- 로딩 오버레이 -->
<div id="loadingOverlay">
    <div class="spinner"></div>
    <p class="loading_text">데이터를 불러오는 중입니다...</p>
</div>
<div id="wrap">
    <jsp:include page="/app/include/Header.jsp" />
    <div id="container">
        <div class="content">
            <div class="title_set">
                <h5 class="page_tit">
                    <p>제조 지시서</p><i><img src="/images/svg/location_arrow.svg"></i><b>진행현황</b>
                </h5>
            </div>
        </div>
    </div>
</div>
<jsp:include page="/app/include/FooterDocType.jsp" />