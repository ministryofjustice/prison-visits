$(function () {
  // Expanding details/summary polyfill
  $('details').details();
  
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

  $('.js-SumbitOnce').on('click', function () {
    var but = $(this);
    but[but.get(0).tagName == 'INPUT' ? 'val' : 'text'](but.data('alt')).addClass('disabled');
  });
});

// Hacks to show GOV.UK images when offline
// $('#logo img').attr('src', '/assets/gov.uk_logotype-2x.png');
// $('#footer .footer-meta .copyright a').css('backgroundImage', 'url(/assets/govuk-crest-2x.png)');
// $('.footer-meta .footer-meta-inner .open-government-licence h2 img').attr('src', '/assets/open-government-licence_2x.png');

moj.are_cookies_enabled = function () {
  var cookieEnabled = (navigator.cookieEnabled) ? true : false;

  if (typeof navigator.cookieEnabled == "undefined" && !cookieEnabled) {
    document.cookie="testcookie";
    cookieEnabled = (document.cookie.indexOf("testcookie") != -1) ? true : false;
  }
  return (cookieEnabled);
};

moj.show_cookie_message = function () {
  if (!moj.are_cookies_enabled() &&  $('body.visit').length) {
    $('noscript').after( $('noscript').text() );
  }
}();

moj.focusAriaAlert = function() {
    var ariaAlert = document.getElementById('error-summary');
    if(ariaAlert){
        $(ariaAlert).focus();
    }
}();
