// Timeout prompt for MOJ
// Dependencies: moj, jQuery, Handlebars

(function () {

  'use strict';

  moj.Modules.timeoutPrompt = {
    timeoutDuration: 1000 * 60 * 17, // ms * s * m = 17 minutes
    respondDuration: 1000 * 60 * 3,
    timeout: null,
    respond: null,
    template: '#tmpl-timeout',
    exitPath: '/abandon',

    init: function () {
      this.cacheEls();
      if (this.$tmpl.length) {
        this.startTimeout(this.timeoutDuration);
      }
    },

    cacheEls: function() {
      this.$tmpl = $(this.template);
      this.notice = this.getTemplate(this.$tmpl);
    },

    startTimeout: function (ms) {
      var self = this;
      this.timeout = setTimeout($.proxy(self.warning, self, self.respondDuration), ms);
    },

    getTemplate: function($tmpl) {
      var self = this,
          template;

      if ($tmpl.length) {
        template = Handlebars.compile($tmpl.html());

        return template({
          respondTime: self.respondDuration / 60 / 1000
        });
      }
    },

    warning: function (ms) {
      var self = this;

      $(self.notice)
        .insertBefore(self.template)
        .focus()
        .end()
        .find('#extend-timeout')
        .on('click', $.proxy(self.removeWarning, self));

      self.respond = setTimeout($.proxy(self.redirect, self), ms);
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
        self.startTimeout();
        clearTimeout(self.respond);
      });
    }
  };

}());
