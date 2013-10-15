//= require Date.format
//= require Array.move

//= require jquery
//= require jquery_ujs

//= require jquery-ui.custom.min
//= require fullcalendar.min

//= require moj
//= require modules/moj.tabs
//= require moj.slot-picker
//= require visitors
//= require date-picker

moj.init();

$('html').removeClass('no-js').addClass('js');

// Hacks to show GOV.UK images when offline
// $('#logo img').attr('src', '/assets/gov.uk_logotype-2x.png');
// $('#footer .footer-meta .copyright a').css('backgroundImage', 'url(/assets/govuk-crest-2x.png)');
// $('.footer-meta .footer-meta-inner .open-government-licence h2 img').attr('src', '/assets/open-government-licence_2x.png');