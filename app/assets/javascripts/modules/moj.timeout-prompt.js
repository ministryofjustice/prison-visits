// Timeout prompt for MOJ
// Dependencies: moj, jQuery, Handlebars

(function () {

  'use strict';

  moj.Modules.timeoutPrompt = {
    timeoutDuration: 1000 * 60 * 17, // ms * s * m = 17 minutes
    respondDuration: 1000 * 60 * 3,
    timeout: null,
    respond: null,
    insertBefore: '#cookies-required',
    template: '#tmpl-timeout',
    exitPath: '/abandon',

    init: function () {
      this.initTimeout();
    },

    initTimeout: function () {
      var self = this;
      this.timeout = setTimeout($.proxy(self.warning, self), self.timeoutDuration);
    },

    warning: function () {
      var self = this,
          $tmpl = $(self.template),
          template;

      if ($tmpl.length) {
        
        template = Handlebars.compile($tmpl.html());
        
        $(template({
            respondTime: self.respondDuration / 60 / 1000
          }))
          .insertBefore(self.insertBefore)
          .focus()
          .end()
          .find('#extend-timeout')
          .on('click', $.proxy(self.removeWarning, self));

        self.respond = setTimeout($.proxy(self.redirect, self), self.respondDuration);
      }
    },

    redirect: function () {
      window.location.href = this.exitPath;
    },

    removeWarning: function () {
      $('#timeout-prompt').remove();
      clearTimeout(this.timeout);
      this.refreshSession();
    },

    refreshSession: function () {
      var self = this;
      $.ajax({
        url: $('#logo img').attr('src'),
        cache: false
      }).done(function () {
        self.initTimeout();
        clearTimeout(self.respond);
      });
    }
  };

}());
