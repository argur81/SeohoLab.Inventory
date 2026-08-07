//쿠키 가져오기
function getCookie( name ) {
  var nameOfCookie = name + "=";
  var x = 0;
  while ( x <= document.cookie.length )
  {
      var y = (x+nameOfCookie.length);
      if ( document.cookie.substring( x, y ) == nameOfCookie ) {
          if ( (endOfCookie=document.cookie.indexOf( ";", y )) == -1 )
              endOfCookie = document.cookie.length;
          return unescape( document.cookie.substring( y, endOfCookie ) );
      }
      x = document.cookie.indexOf( " ", x ) + 1;
      if ( x == 0 )
          break;
  }
  return "";
}

// 24시간 기준 쿠키 설정하기
// expiredays 후의 클릭한 시간까지 쿠키 설정
function setCookie( name, value, expiredays ) {
  var todayDate = new Date();
  todayDate.setDate( todayDate.getDate() + expiredays );
  document.cookie = name + "=" + escape( value ) + "; path=/; expires=" + todayDate.toGMTString() + ";";
}

// common.js 파일 수정

function checkPassword(curPw, newPw, newPwCf){
    // 1. 새 비밀번호 입력란 Parsley 인스턴스
    var passwordField = $('#newPassword').parsley();
    // 2. [추가] 새 비밀번호 확인 입력란 Parsley 인스턴스
    var confirmField = $('#newPasswordConfirm').parsley();

    var alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    var number = "1234567890";
    var sChar = "-_=+\|()*&^%$#@!~`?></;,.:'";

    var alphaCheck = false;
    var numberCheck = false;
    var sCharCheck = false;

    // --- [새 비밀번호 복잡도 체크] ---
    if(8 <= newPw.length && newPw.length <= 15){
        for(var i=0; i<newPw.length; i++){
            if(sChar.indexOf(newPw.charAt(i)) != -1) sCharCheck = true;
            if(alpha.indexOf(newPw.charAt(i)) != -1) alphaCheck = true;
            if(number.indexOf(newPw.charAt(i)) != -1) numberCheck = true;
        }

        var checkCount = 0;
        if(alphaCheck) checkCount++;
        if(numberCheck) checkCount++;
        if(sCharCheck) checkCount++;

        if(checkCount < 2){
            if (window.ParsleyUI) {
                window.ParsleyUI.removeError(passwordField, "passwordError");
                window.ParsleyUI.addError(passwordField, "passwordError", "영문, 숫자, 특수문자 중 2가지 이상을 조합해야 합니다.");
            } else {
                passwordField.removeError("passwordError");
                passwordField.addError("passwordError", {message: "영문, 숫자, 특수문자 중 2가지 이상을 조합해야 합니다."});
            }
            return false;
        }
    } else {
        if (window.ParsleyUI) {
            window.ParsleyUI.removeError(passwordField, "passwordError");
            window.ParsleyUI.addError(passwordField, "passwordError", "비밀번호는 8~15자로 입력해주세요.");
        } else {
            passwordField.removeError("passwordError");
            passwordField.addError("passwordError", {message: "비밀번호는 8~15자로 입력해주세요."});
        }
        return false;
    }

    // 복잡도 통과 시 해당 에러 제거
    if (window.ParsleyUI) {
        window.ParsleyUI.removeError(passwordField, "passwordError");
    } else {
        passwordField.removeError("passwordError");
    }

    // --- [비밀번호 일치 여부 체크] ---
    // 수정: 에러 대상을 confirmField(#newPasswordConform)로 변경
    if (newPw != newPwCf) {
        if (window.ParsleyUI) {
            window.ParsleyUI.removeError(confirmField, "passwordMatchError");
            window.ParsleyUI.addError(confirmField, "passwordMatchError", "입력한 비밀번호가 서로 일치하지 않습니다.");
        } else {
            confirmField.removeError("passwordMatchError");
            confirmField.addError("passwordMatchError", { message: "입력한 비밀번호가 서로 일치하지 않습니다." });
        }
        return false;
    } else {
        // 일치하면 에러 제거
        if (window.ParsleyUI) {
            window.ParsleyUI.removeError(confirmField, "passwordMatchError");
        } else {
            confirmField.removeError("passwordMatchError");
        }
    }

    // --- [이전 비밀번호 사용 여부 체크] ---
    // 대상: passwordField(#newPassword)
	if(curPw == newPw) {
        if (window.ParsleyUI) {
		    window.ParsleyUI.removeError(passwordField, "passwordPrevError"); // 에러 이름 구분
            window.ParsleyUI.addError(passwordField, "passwordPrevError", "이전에 사용한 비밀번호는 사용이 불가합니다. \n다시 입력해주세요.");
        } else {
            passwordField.removeError("passwordPrevError");
            passwordField.addError("passwordPrevError", {message: "이전에 사용한 비밀번호는 사용이 불가합니다. \n다시 입력해주세요."});
        }
		return false;
	} else {
         if (window.ParsleyUI) {
            window.ParsleyUI.removeError(passwordField, "passwordPrevError");
        } else {
            passwordField.removeError("passwordPrevError");
        }
    }

    return true;
}

function checkPasswordLogin(curPw, newPw, newPwCf) {
    // 1. 새 비밀번호 입력란 Parsley 인스턴스
    var passwordField = $('#newLPassword').parsley();
    // 2. [추가] 새 비밀번호 확인 입력란 Parsley 인스턴스
    var confirmField = $('#newLPasswordConfirm').parsley();

    var alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    var number = "1234567890";
    var sChar = "-_=+\|()*&^%$#@!~`?></;,.:'";

    var alphaCheck = false;
    var numberCheck = false;
    var sCharCheck = false;

    // --- [새 비밀번호 복잡도 체크] ---
    if (8 <= newPw.length && newPw.length <= 15) {
        for (var i = 0; i < newPw.length; i++) {
            if (sChar.indexOf(newPw.charAt(i)) != -1) sCharCheck = true;
            if (alpha.indexOf(newPw.charAt(i)) != -1) alphaCheck = true;
            if (number.indexOf(newPw.charAt(i)) != -1) numberCheck = true;
        }

        var checkCount = 0;
        if (alphaCheck) checkCount++;
        if (numberCheck) checkCount++;
        if (sCharCheck) checkCount++;

        if (checkCount < 2) {
            if (window.ParsleyUI) {
                window.ParsleyUI.removeError(passwordField, "passwdErrorLogin");
                window.ParsleyUI.addError(passwordField, "passwdErrorLogin", "영문, 숫자, 특수문자 중 2가지 이상을 조합해야 합니다.");
            } else {
                passwordField.removeError("passwdErrorLogin");
                passwordField.addError("passwdErrorLogin", { message: "영문, 숫자, 특수문자 중 2가지 이상을 조합해야 합니다." });
            }
            return false;
        }
    } else {
        if (window.ParsleyUI) {
            window.ParsleyUI.removeError(passwordField, "passwdErrorLogin");
            window.ParsleyUI.addError(passwordField, "passwdErrorLogin", "비밀번호는 8~15자로 입력해주세요.");
        } else {
            passwordField.removeError("passwdErrorLogin");
            passwordField.addError("passwdErrorLogin", { message: "비밀번호는 8~15자로 입력해주세요." });
        }
        return false;
    }

    // 복잡도 통과 시 에러 제거
    if (window.ParsleyUI) {
        window.ParsleyUI.removeError(passwordField, "passwdErrorLogin");
    } else {
        passwordField.removeError("passwdErrorLogin");
    }

    // --- [비밀번호 일치 여부 체크] ---
    // 수정: 에러 대상을 confirmField(#newLPasswordConform)로 변경
    if (newPw != newPwCf) {
        if (window.ParsleyUI) {
            window.ParsleyUI.removeError(confirmField, "passwdMatchErrorLogin");
            window.ParsleyUI.addError(confirmField, "passwdMatchErrorLogin", "입력한 비밀번호가 서로 일치하지 않습니다.");
        } else {
            confirmField.removeError("passwdMatchErrorLogin");
            confirmField.addError("passwdMatchErrorLogin", { message: "입력한 비밀번호가 서로 일치하지 않습니다." });
        }
        return false;
    } else {
        if (window.ParsleyUI) {
            window.ParsleyUI.removeError(confirmField, "passwdMatchErrorLogin");
        } else {
            confirmField.removeError("passwdMatchErrorLogin");
        }
    }

    // --- [이전 비밀번호 사용 여부 체크] ---
    // 대상: passwordField(#newLPassword)
    if (curPw == newPw) {
        if (window.ParsleyUI) {
            window.ParsleyUI.removeError(passwordField, "passwdPrevErrorLogin");
            window.ParsleyUI.addError(passwordField, "passwdPrevErrorLogin", "이전에 사용한 비밀번호는 사용이 불가합니다. \n다시 입력해주세요.");
        } else {
            passwordField.removeError("passwdPrevErrorLogin");
            passwordField.addError("passwdPrevErrorLogin", { message: "이전에 사용한 비밀번호는 사용이 불가합니다. \n다시 입력해주세요." });
        }
        return false;
    } else {
        if (window.ParsleyUI) {
            window.ParsleyUI.removeError(passwordField, "passwdPrevErrorLogin");
        } else {
            passwordField.removeError("passwdPrevErrorLogin");
        }
    }

    return true;
}

  function validatePassword(password) {
      const result = {
          valid: true,
          message: ''
      };

      // 1️⃣ 영문자 + 숫자 + 특수문자 조합 (8~20자)
      const pattern = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,20}$/;
      if (!pattern.test(password)) {
          result.valid = false;
          result.message = "비밀번호는 영문자, 숫자, 특수문자를 모두 포함하여 8~20자로 입력해 주세요.";
          return result;
      }

      // 2️⃣ 동일한 문자 3회 이상 연속 사용 불가 (예: aaa, !!!)
      if (/(.)\1\1/.test(password)) {
          result.valid = false;
          result.message = "동일한 문자는 3회 이상 연속으로 사용할 수 없습니다.";
          return result;
      }

      // 3️⃣ 연속된 숫자나 문자 3회 이상 사용 불가 (예: 123, abc)
      const sequencePattern = /(012|123|234|345|456|567|678|789|890|abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)/i;
      if (sequencePattern.test(password)) {
          result.valid = false;
          result.message = "연속된 숫자나 문자를 3회 이상 사용할 수 없습니다.";
          return result;
      }

      return result;
  }

  function showToast(msg){
    nativeToast({
			message: msg,
			position: 'south',
			timeout: 3000,
			type: 'warning'
		})
  }

  /**
   * 페이지네이션 HTML을 생성해주는 함수
   *
   * @param {string} moveFuncName - 페이지 이동 시 호출할 함수명 (예: 'goPage')
   * @param {number} pageSize - 한 화면에 보여줄 페이지 수 (예: 10)
   * @param {number} totalCount - 전체 데이터 개수
   * @param {number} currentPage - 현재 페이지 번호
   * @returns {string} 페이지네이션 HTML 문자열
   */
  function createPagination(moveFuncName, pageSize, totalCount, currentPage) {
    const totalPage = Math.ceil(totalCount / pageSize);
    if (totalPage === 0) return '';

    const groupSize = 10;
    const groupStart = Math.floor((currentPage - 1) / groupSize) * groupSize + 1;
    const groupEnd = Math.min(groupStart + groupSize - 1, totalPage);

    let html = ``;

    /* 이전 페이지 */
    html += `
      <button type="button" title="이전페이지"
        onclick="${moveFuncName}(${Math.max(1, currentPage - 1)})"
        ${currentPage === 1 ? 'disabled' : ''}>
        <img src="/images/svg/paging_prev.svg" alt="이전페이지">
      </button>
    `;

    /* 페이지 번호 */
    html += `<ul>`;

    for (let i = groupStart; i <= groupEnd; i++) {
      if (i === currentPage) {
        html += `
          <li>
            <span>${i}</span>
          </li>
        `;
      } else {
        html += `
          <li>
            <a href="javascript:void(0);" onclick="${moveFuncName}(${i})">${i}</a>
          </li>
        `;
      }
    }

    html += `</ul>`;

    /* 다음 페이지 */
    html += `
      <button type="button" title="다음페이지"
        onclick="${moveFuncName}(${Math.min(totalPage, currentPage + 1)})"
        ${currentPage === totalPage ? 'disabled' : ''}>
        <img src="/images/svg/paging_next.svg" alt="다음페이지">
      </button>
    `;

    html += ``;

    return html;
  }

  function openPopUp(url, name, width, height)  {
  	var xPos = (document.body.clientWidth/2)- (width/2);
  	xPos += window.screenLeft;
  	var yPos = (screen.availHeight / 2) - (height / 2);
  	var args = 'scrollbars=no,toolbar=no,location=no,left='+xPos+',top='+yPos+',width='+width+',height='+height;
  	var oWin = window.open(url, name, args);
  	return oWin;
  }

  function commaNum(str) {
  	str = String(str);
  	return str.replace(/(\d)(?=(?:\d{3})+(?!\d))/g, '$1,');
  }

  function formatDate(date,gb) {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}${gb}${m}${gb}${d}`;
  }

  function formatStrDate(dateStr, gb) {
      if (!dateStr || dateStr.length !== 8) return dateStr;
      return dateStr.substring(0, 4) + gb +
             dateStr.substring(4, 6) + gb +
             dateStr.substring(6, 8);
  }

  function byteToKB(bytes, decimals = 2) {
    if (!bytes || bytes <= 0) return '0 KB';

    const kb = bytes / 1024;
    return `${kb.toFixed(decimals)} KB`;
  }

  function showLoading() {
    if ($('.loading').length === 0) {
      const loading = document.createElement('div');
      loading.className = 'loading';
      loading.innerHTML = `<div class="loading__inner">
      <svg width="310" height="150" viewBox="0 0 320 90" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path id="loading-indicator-p" d="M26.4748 15.4601C11.627 15.4601 0.0425991 27.1215 0.0425991 42.3386V77.9632C0.0425991 77.9632 -0.432878 82.6675 1.79322 85.9804C3.32771 88.2552 5.46736 89.8896 7.82313 90C9.50892 89.8454 9.59537 87.7251 9.59537 87.7251V63.2761C14.134 67.0527 20.0126 69.2393 26.4748 69.2393C41.301 69.2393 52.9502 57.5779 52.9502 42.3607C52.9502 27.1435 41.301 15.4601 26.4748 15.4601ZM26.4748 59.8307C17.0949 59.8307 9.50892 51.9902 9.50892 42.2945C9.50892 32.5988 17.0949 24.7141 26.4748 24.7141C35.8547 24.7141 43.4623 32.5767 43.4623 42.2945C43.4623 52.0123 35.8547 59.8307 26.4748 59.8307Z" fill="white" />
      <path id="loading-indicator-o" d="M83.7234 24.7362C93.1464 24.7362 100.646 32.7534 100.646 42.3166C100.646 51.8797 93.1248 59.9411 83.7234 59.9411C74.3219 59.9411 66.8007 51.8356 66.8007 42.3166C66.8007 32.7975 74.3219 24.7362 83.7234 24.7362ZM83.7234 15.4601C68.8971 15.4601 57.2695 27.1215 57.2695 42.3386C57.2695 57.5558 68.8971 69.2172 83.7234 69.2172C98.5496 69.2172 110.177 57.5558 110.177 42.3386C110.177 27.1215 98.5496 15.4601 83.7234 15.4601Z" fill="white" />
      <path id="loading-indicator-s" d="M151.441 47.1999C154.488 47.3324 155.267 48.8563 154.208 51.5287C152.262 56.4318 145.519 60.3631 139.641 60.2968C132.422 60.2085 128.813 56.4981 126.046 53.5606C123.258 50.6011 118.179 50.557 116.537 51.1754C114.916 51.7938 115.672 54.3557 116.342 55.7251C120.708 64.3165 130.218 69.0649 139.165 69.1754C148.718 69.3079 157.277 64.6036 162.269 56.4097C167.283 48.1275 165.122 38.1668 153.689 38.0343L127.84 37.703C124.058 37.6588 123.691 35.2293 124.793 32.9545C127.235 27.8747 133.157 24.2527 139.965 24.3189C146.773 24.3631 150.469 28.449 152.716 30.7238C155.115 33.087 160.151 33.8379 162.377 32.7116C163.501 32.1373 163.415 30.6134 162.399 28.6257C158.098 20.233 148.934 15.5729 139.554 15.4625C131.536 15.352 122.502 19.1066 117.034 27.7201C112.517 34.8539 112.755 46.714 128.748 46.9128L151.441 47.1999Z" fill="white"/>
      <path id="loading-indicator-w" d="M169.133 18.9386C170.559 17.3263 172.958 17.6134 174.86 18.1214C178.794 19.1594 181.02 22.892 182.425 26.492C185.472 34.3987 187.093 43.5644 189.967 51.6257L190.443 51.957L199.109 19.0048C199.909 17.1496 205.745 17.4809 206.782 18.4527L215.989 52.6417L223.899 26.249C225.498 22.4502 227.379 19.0711 231.658 18.0772C234.77 17.3484 238.25 17.4588 236.629 21.7214L220.592 66.5779C220.182 67.9472 219.166 68.3226 217.848 68.4552C216.27 68.5877 213.028 68.7644 212.185 67.2183L203.302 36.1435C202.697 36.0772 202.935 36.1435 202.848 36.4969C199.779 46.7668 197.143 57.1693 193.879 67.3729C192.863 68.9631 187.309 68.7644 186.228 67.7705L169.133 20.3521V18.9607V18.9386Z" fill="white"/>
      <path id="loading-indicator-e" d="M292.013 42.6053C295.341 40.6617 293.331 34.7206 292.186 31.8716C281.942 6.07525 243.017 12.0384 241.418 40.3305C239.711 70.6323 281.531 79.4446 292.186 51.8372C293.483 48.5022 294.174 45.9403 289.441 46.2716C282.785 46.7354 281.682 53.2065 276.668 56.5415C265.905 63.6752 251.965 55.8568 251.057 43.2458H290.349C290.522 43.2458 291.754 42.7378 292.013 42.6053ZM252.894 33.9476C259.292 21.5575 276.171 21.6679 282.676 33.9476H252.894Z" fill="white"/>
      <path id="loading-indicator-l" d="M309.946 9.02766C309.946 9.02766 309.946 8.85098 309.946 8.76263C309.622 6.6203 308.843 4.50006 307.439 2.8657C305.321 0.347909 300.544 -2.16988 300.328 3.08656V57.6387C300.328 57.6387 300.328 57.727 300.328 57.7933C300.674 62.2326 302.749 65.8988 306.92 67.489C307.093 67.5553 307.287 67.5994 307.482 67.5994H308.022C308.519 67.5994 308.973 67.3786 309.297 66.981L309.341 66.9369C309.557 66.6497 309.686 66.3185 309.686 65.9651C310.313 47.0817 309.773 28.0215 309.946 9.07184V9.02766Z" fill="white"/>
      </svg>
    </div>`;
      document.body.appendChild(loading);
      document.body.classList.add('noscroll');

      setTimeout(function () {
        loading.classList.add('loading--show');
      }, 100);
    }
  }

  function hideLoading() {
    if ($('.loading').length > 0) {
      const loading = document.querySelector('.loading');
      loading.classList.remove('loading--show');
      setTimeout(function () {
        loading.remove();
        document.body.classList.remove('noscroll');
      }, 500);
    }
  }

  $(function() {
/*
	$.datepicker.setDefaults({
      dateFormat: "yy-mm-dd",     // 표시 형식 (예: 2025-11-12)
      changeYear: true,           // 년도 선택 가능
      changeMonth: true,          // 월 선택 가능
      yearRange: "c-100:c+10",    // 현재 기준 -100년 ~ +10년
      prevText: "이전 달",
      nextText: "다음 달",
      monthNames: ["1월", "2월", "3월", "4월", "5월", "6월",
                   "7월", "8월", "9월", "10월", "11월", "12월"],
      monthNamesShort: ["1월", "2월", "3월", "4월", "5월", "6월",
                        "7월", "8월", "9월", "10월", "11월", "12월"],
      dayNames: ["일", "월", "화", "수", "목", "금", "토"],
      dayNamesShort: ["일", "월", "화", "수", "목", "금", "토"],
      dayNamesMin: ["일", "월", "화", "수", "목", "금", "토"],
      showMonthAfterYear: true,
      yearSuffix: "년"
    });
*/
  });
