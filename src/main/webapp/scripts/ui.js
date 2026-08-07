$(document).ready(function () {
    //GNB
    $('header .gnb li.has_depth p').click(function(){
        if($(this).parent('li').hasClass('on')){
            $(this).parent('li').removeClass('on');
            $(this).next('.depth').stop().slideUp();
        }else{
            $('header .gnb li').removeClass('on');
            $('header .gnb li.has_depth .depth').stop().slideUp();
            $(this).parent('li').addClass('on');
            $(this).next('.depth').stop().slideDown();
        }
    });
    $('header .gnb li.no_depth').click(function(){
        $('header .gnb li').removeClass('on');
        $('header .gnb li.has_depth .depth').stop().slideUp();
        $(this).addClass('on');
    });
    $('header .gnb li.has_depth.on .depth').stop().slideDown();
    //GNB - Mobile
    $('header .logo .mo_menu').click(function(){
        $('header .menu').stop().animate({'left' : 0});
    });
    $('header .menu .mobile_ctrl .close').click(function(){
        $('header .menu').stop().animate({'left' : '-100%'});
        return false;
    });
    //근태관리 그래프
    function workTimeGraph() {
        var workTime = $('.content.atndn_mgmt .viewer .time > p .total').text();
        var maxTime = $('.content.atndn_mgmt .viewer .time > p .max').text();
        var workTimePer = (workTime / maxTime) * 100;
        $('.content.atndn_mgmt .viewer .chart .bar .data').css({
            'width' : workTimePer + '%'
        })
    }
    workTimeGraph();
    //공통 Select
    $('.Select > .value').click(function(){
        $(this).addClass('focus');
        $(this).next('.list').stop().slideDown();
    });
    $('.Select .list li').click(function(){
        var value = $(this).text();
        $(this).parent('.list').prev('.value').text(value);
        $(this).parent('.list').prev('.value').removeClass('focus');
        $(this).parent('.list').stop().slideUp();
    });
    $('.Select').mouseleave(function(){
        $(this).find('.value').removeClass('focus');
        $(this).find('.list').stop().slideUp();
    });
    //이미지 관리 -> 이미지선택
    $('.content.image_mgmt .checkBox').click(function(){
        if($(this).find('input').is(':checked') == true){
            $(this).find('input').prop('checked', true);
            $(this).parent('.thumb').addClass('on');
        }else{
            $(this).find('input').prop('checked', false);
            $(this).parent('.thumb').removeClass('on');
        }
    });
    $('.content.image_mgmt .checkBox input[type="checkbox"]').on('change', function() {
        if($(this).is(':checked') == true){
            $(this).prop('checked', true);
            $(this).parents('.thumb').addClass('on');
        }else{
            $(this).prop('checked', false);
            $(this).parents('.thumb').removeClass('on');
        }
        // 체크된 체크박스의 개수 파악
        let checkedCount = $('.content.image_mgmt .checkBox input[type="checkbox"]:checked').length;
        $('.content.image_mgmt.for_mobile .mobile_chk_fix > p i').text(checkedCount)
        console.log(checkedCount)
        if (checkedCount >= 1) {
            $('.content.image_mgmt.for_mobile .mobile_chk_fix').css('display' , 'flex');
        } else {
            $('.content.image_mgmt.for_mobile .mobile_chk_fix').hide();
        }
    });
    $(window).on('scroll', function() {
        let scrollPos = $(window).scrollTop() + $(window).height();
        let docHeight = $(document).height();
        if (scrollPos >= docHeight - 50) {
            var footerHeight = $('footer').outerHeight();
            $('.content.for_mobile .mobile_chk_fix').stop().animate({'bottom' : footerHeight});
        }else{
            $('.content.for_mobile .mobile_chk_fix').stop().animate({'bottom' : 0});
        }
    });
    //data-width / data-height가 설정되어 있는 요소
    $('.Select, input.inputText, button.Button, .pop_data').each(function(){
        var dataWidth = $(this).attr('data-width');
        $(this).css('width' , dataWidth);
    });
    $('textarea.textArea').each(function(){
        var dataHeight = $(this).attr('data-height');
        $(this).css('height' , dataHeight);
    });
    //글자수 textarea
    $('.textArea_max').each(function(){
        var maxLength = $(this).find('textarea').attr('maxlength');
        formattedValue = maxLength.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        $(this).find('p span').text(formattedValue);
    });
    $('.textArea_max textarea').on('input', function() {
        var content = $(this).val();
        var maxLength = $(this).attr('maxlength');
        var countNoneSpace = content.replace(/\B(?=(\d{3})+(?!\d))/g, ',').length;
        $(this).parent('.textArea_max').find('p i').text(countNoneSpace);
        if (content.length > maxLength) {
            $(this).val(content.substring(0, maxLength)); // 초과분 제거
            alert(countNoneSpace+'자 미만으로 작성해 주세요.')
        }
    });
    //Grid Data Hover
    $('.default_girid .has_hover > span').each(function(){
        var objData = $(this).html();
        $(this).next('.hover').html(objData);
    });
    $('.default_girid .has_hover > span').hover(function(){
        $(this).next('.hover').fadeIn();
    }, function(){
        $(this).next('.hover').fadeOut();
    });
    //이미지 결재 관리 거절선택
    $('.content.detailView dl.approval .radioButton').click(function(){
        if ($('#refusal').is(':checked')) {
            $('.content.detailView dl.reason').css('display' , 'flex');
        } else {
            $('.content.detailView dl.reason').hide()
        }
    });
    //공통 팝업
    $('.layer_popup .pop_data .head button').click(function(){
        $(this).parents('.layer_popup').hide();
    });
    //이미지승인 요청 수신자선택(모바일)
    $('.pop_data.people_pop fieldset.for_mobile .search_open').click(function(){
        $('.pop_data.people_pop fieldset.for_mobile .search_field').fadeIn();
        $('.pop_data.people_pop fieldset.for_mobile .search_field > div').addClass('open');
    });
    $('.pop_data.people_pop fieldset.for_mobile .search_field .close').click(function(){
        $('.pop_data.people_pop fieldset.for_mobile .search_field').fadeOut();
        $('.pop_data.people_pop fieldset.for_mobile .search_field > div').removeClass('open');
    });
    $('.pop_data.people_pop .grid .checkBox input[type="checkbox"]').on('change', function() {
        if($(this).is(':checked') == true){
            $(this).prop('checked', true);
        }else{
            $(this).prop('checked', false);
        }
        // 체크된 체크박스의 개수 파악
        let checkedCount = $('.pop_data.people_pop .grid .checkBox input[type="checkbox"]:checked').length;
        $('.pop_data.people_pop fieldset.for_mobile .mobile_chk_fix > p i').text(checkedCount)
        console.log(checkedCount)
        if (checkedCount >= 1) {
            $('.pop_data.people_pop fieldset.for_mobile .mobile_chk_fix').css('display' , 'flex');
        } else {
            $('.pop_data.people_pop fieldset.for_mobile .mobile_chk_fix').hide();
        }
    });
    //그리드 체크박스 체크 유무
    $('.default_girid .grid .checkBox input[type="checkbox"]').on('change', function() {
        if($(this).is(':checked') == true){
            $(this).prop('checked', true);
        }else{
            $(this).prop('checked', false);
        }
        // 체크된 체크박스의 개수 파악
        let checkedCount = $('.default_girid .grid .checkBox input[type="checkbox"]:checked').length;
        $('.mobile_chk_fix > p i').text(checkedCount)
        console.log(checkedCount)
        if (checkedCount >= 1) {
            $('.mobile_chk_fix').css('display' , 'flex');
        } else {
            $('.mobile_chk_fix').hide();
        }
    });
    //모바일 타이틀
    function imageMgmtTitle(){
        if($(window).width() <= 780){
            var pageTitle = $('.content .title_set h5').text();
            $('header .logo .title').text(pageTitle);
            $('header .logo > a').hide();
            $('.content .title_set h5').hide();
            if($('#container .content').hasClass('atndn_mgmt')){
                $('header .logo .title').hide();
                $('header .logo > a').show();
                $('.content .title_set h5').show();
            }
        }else{
            $('header .logo .title').hide();
            $('header .logo > a').show();
            $('.content .title_set h5').show();
        }
    }
    function viewportMobieDevice(){
        if($(window).width() <= 780){
            $('#container .content').addClass('for_mobile');
        }else{
            $('#container .content').removeClass('for_mobile');
        }
    }
    imageMgmtTitle();
    viewportMobieDevice();
    $(window).resize(function(){
        imageMgmtTitle();
        viewportMobieDevice();
    });
    //그리드 Hover 모바일용
    function gridHoverFunction(){
        $('#container .content.for_mobile .default_girid .has_hover > span').each(function(){
            var firstText = $(this).find('i:first-child').text();
            var itemEa = $(this).find('i').length;
            var viewEa = itemEa - 1
            if(itemEa > 1) {
                $(this).text(firstText + '외' + viewEa + '명');
            }
        });
    }
    gridHoverFunction();
    //키워드검색(모바일)
    $('.content.for_mobile .search_open_btn').click(function(){
        $('.content.for_mobile .data_search').fadeIn();
        $('.content.for_mobile .data_search > div').addClass('open');
    });
    $('.content.for_mobile .data_search > div > h5 .close').click(function(){
        $('.content.for_mobile .data_search').fadeOut();
        $('.content.for_mobile .data_search > div').removeClass('open');
    });
});
$(document).ready(function(){
    //이미지팝업 슬라이더
    function imgPopupSlider(){
        var imgNumber = $('.layer_popup .pop_data.image_pop .body .img_data ul li').length
        if(imgNumber > 1) {
            var swiper = new Swiper('.layer_popup .image_pop .body .img_data', {
                navigation: {
                    nextEl: '.layer_popup .image_pop .body .next',
                    prevEl: '.layer_popup .image_pop .body .prev',
                },
            });
        }
    }
    imgPopupSlider();
});
