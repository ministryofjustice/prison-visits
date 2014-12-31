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

  function getAge(d1, d2){
    d2 = d2 || new Date();
    var diff = d2.getTime() - d1.getTime();
    return Math.floor(diff / (1000 * 60 * 60 * 24 * 365.25));
  }

  $('body').on('change', '.known-date input', function() {

    var dob, el,
        known = $(this).closest('.known-date'),
        year = known.find('.year').val(),
        month = known.find('.month').val(),
        day = known.find('.day').val();

    el = $(this).closest('.additional-visitor').find('h2');

    if (year!=='' && month !== '' && day !== '') {
      dob = new Date(year, month-1, day);

      el.find('small').remove();

      if (getAge(dob) > 17) {
        el.append(' <small class="adult">Adult</small>');
      } else {
        el.append(' <small class="child">Child</small>');
      }
    }
  });

  $('.known-date input').change();

  $('#ad-help').on('click', function () {
    ga('send', 'event', 'external-link', 'ad-help');
  });

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

  $('.BookingCalendar input[type=radio]').on('click', function() {
    var date = moj.Helpers.dateFromIso($(this).val()),
      days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'],
      months = ['January','February','March','April','May','June','July','August','September','October','November','December'];

    $(this).closest('.BookingCalendar').siblings('p').find('span').text(days[date.getDay()] +' '+ date.getDate() +' '+ months[date.getMonth()]);
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
