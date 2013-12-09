//= require Date.format
//= require Array.move
//= require Array.foreachwithindex
//= require Array.indexof

//= require lodash
//= require jquery.details

//= require moj
//= require modules/moj.cookie-message
//= require modules/moj.hijacks
// require modules/moj.effects
//= require moj.slot-picker
//= require visitors
//= require date-picker

moj.init();

$(function () {
  $('details').details();
});

// Hacks to show GOV.UK images when offline
// $('#logo img').attr('src', '/assets/gov.uk_logotype-2x.png');
// $('#footer .footer-meta .copyright a').css('backgroundImage', 'url(/assets/govuk-crest-2x.png)');
// $('.footer-meta .footer-meta-inner .open-government-licence h2 img').attr('src', '/assets/open-government-licence_2x.png');
