/*jslint browser: true, evil: false, plusplus: true, white: true, indent: 2, nomen: true */
/*global moj, $ */

// Timeout prompt for MOJ
// Dependencies: moj, jQuery

(function () {

  "use strict";

  moj.Modules.timeoutPrompt = {
    timeoutDuration: 1000 * 60 * 19, // ms * s * m = 19 minutes
    timeout: null,

    init: function () {
      this.initTimeout();
    },

    time: function () {
      return new Date().getTime();
    },

    initTimeout: function () {
      var startTime = this.time();
      this.timeout = setTimeout(this.warning, this.timeoutDuration - (this.time() - startTime));
    },

    warning: function () {
      var self = moj.Modules.timeoutPrompt,
        noscript = $('noscript')[0],
        template = ['<div id="timeoutPrompt" role="alertdialog" aria-labelledby="timeoutTitle" aria-describedby="timeoutDesc" class="validation-summary alert-dialog">',
                      '<h2 id="timeoutTitle">Your session will will expire in 60 seconds</h2>',
                      '<p id="timeoutDesc">would you like to continue?</p>',
                      '<button id="confirmTimeout" class="button button-primary">Yes</button>',
                    '</div>'].join('');
      $(template).insertBefore(noscript)
        .focus()
        .end()
        .find('#confirmTimeout')
        .on('click', function confirmButton() {
          $('#timeoutPrompt').remove();
          clearTimeout(self.timeout);
          self.refreshSession();
        });
    },

    refreshSession: function () {
      var self = this;
      $.ajax({
        url: "/assets/gov.uk_logotype_crown.png"
      })
        .done(function () {
          self.initTimeout();
        });
    }
  };

}());