<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/app/include/HeaderDocType.jsp" />
<script>
    $(document).ready(function(){
        var swiper = new Swiper('.content.home', {});
    });
</script>
    <div id="wrap">
        <jsp:include page="/app/include/Header.jsp" />
        <div id="container">
            <div class="content home">
                <ul class="swiper-wrapper">
                    <!--원료-->
                    <li class="swiper-slide">
                        <div class="title_set">
                            <h5 class="page_tit">원료 현황</h5>
                        </div>
                        <section class="dashboard">
                            원료현황
                        </section>
                    </li>
                    <!--//원료-->
                    <!--제품-->
                    <li class="swiper-slide">
                        <div class="title_set">
                            <h5 class="page_tit">제품 현황</h5>
                        </div>
                        <section class="dashboard">
                            제품현황
                        </section>
                    </li>
                    <!--//제품-->
                    <!--부자재-->
                    <li class="swiper-slide">
                        <div class="title_set">
                            <h5 class="page_tit">부자재 현황</h5>
                        </div>
                        <section class="dashboard">
                            부자재 현황
                        </section>
                    </li>
                    <!--//부자재-->
                </ul>
            </div>
        </div>
    </div>
<jsp:include page="/app/include/FooterDocType.jsp" />