$(function () {

  'use strict';

  var $blockLabels;

  // Change appearance of block labels when interacting
  $blockLabels = $('.block-label input[type="radio"], .block-label input[type="checkbox"]');
  new GOVUK.SelectionButtons($blockLabels);

  // Browser confirm dialog
  $(document).on('click', '[data-confirm]', function (e) {
    e.preventDefault();
    if (window.confirm($(this).data('confirm'))) {
      window.location.href = $(this).attr('href');
    }
  });

  $('#ad-help').on('click', function () {
    ga('send', 'event', 'external-link', 'ad-help');
  });


  // Staff processing form

  // Only enable PVO when VO is checked
  $('#confirmation_no_vo').on('change', function() {
    var dis = $('#confirmation_no_pvo');

    if ($(this).is(':checked')) {
      dis.attr('disabled', false);
      dis.closest('label').removeClass('disabled');
    } else {
      if (dis.is(':checked')) { dis.click(); }
      dis.attr('disabled', true);
      dis.closest('label').addClass('disabled');
    }
  }).change();

  // Display date from ISO-8601 format
  $('.BookingCalendar input[type=radio]').on('click', function() {
    var date = moj.Helpers.dateFromIso($(this).val()),
      days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'],
      months = ['January','February','March','April','May','June','July','August','September','October','November','December'];

    $(this).closest('.BookingCalendar').siblings('p').find('span').text(days[date.getDay()] +' '+ date.getDate() +' '+ months[date.getMonth()]);
  });

  // Temporary survey
  $('#survey-no-thanks').on('click', function() {
    $('#user-satisfaction-survey-container').remove();
  });
});


moj.are_cookies_enabled = function () {
  'use strict';

  var cookieEnabled = (navigator.cookieEnabled) ? true : false;

  if (typeof navigator.cookieEnabled === 'undefined' && !cookieEnabled) {
    document.cookie = 'testcookie';
    cookieEnabled = (document.cookie.indexOf('testcookie') !== -1) ? true : false;
  }
  return (cookieEnabled);
};

moj.show_cookie_message = function () {
  'use strict';

  if (!moj.are_cookies_enabled() && $('body.visit').length) {
    $('noscript').after( $('noscript').text() );
  }
}();

moj.focusAriaAlert = function() {
  'use strict';

  var ariaAlert = document.getElementById('error-summary');
  if(ariaAlert){
    $(ariaAlert).focus();
  }
}();
