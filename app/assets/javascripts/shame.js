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
}

moj.show_cookie_message = function () {
  if (!moj.are_cookies_enabled()) {
    $('noscript').after( $('noscript').text() );
  }
}()
