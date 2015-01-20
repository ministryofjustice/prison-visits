// Timeout prompt for MOJ
// Dependencies: moj, jQuery, Handlebars

(function () {

  'use strict';

  window.moj = window.moj || { Modules: {}, Events: $({}) };

  var TimeoutPrompt = function($el, options) {
    this.init($el, options);
    return this;
  };

  TimeoutPrompt.prototype = {

    defaults: {
      timeoutMinutes: 17,
      respondMinutes: 3,
      exitPath: '/abandon'
    },

    timeout: null,
    respond: null,

    init: function ($el, options) {
      this.settings = $.extend({}, this.defaults, options);
      this.settings.timeoutDuration = this.convertToMinutes(this.settings.timeoutMinutes);
      this.settings.respondDuration = this.convertToMinutes(this.settings.respondMinutes);
      this.cacheEls($el);
      this.startTimeout();
    },

    convertToMinutes: function(num) {
      return num * 1000 * 60;
    },

    cacheEls: function($el) {
      this.$el = $el;
      this.notice = this.getTemplate($el);
    },

    startTimeout: function () {
      var self = this;
      this.timeout = setTimeout(
        $.proxy(
          self.warning,
          self,
          self.settings.respondDuration
        ),
        self.settings.timeoutDuration
      );
    },

    getTemplate: function($tmpl) {
      var self = this,
          template;

      if ($tmpl.length) {
        template = Handlebars.compile($tmpl.html());

        return template({
          respondTime: self.settings.respondMinutes
        });
      }
    },

    warning: function (ms) {
      var self = this;

      $(self.notice)
        .insertBefore(self.$el)
        .focus()
        .end()
        .find('#extend-timeout')
        .on('click', $.proxy(self.removeWarning, self));

      self.respond = setTimeout($.proxy(self.redirect, self), ms);
    },

    redirect: function () {
      window.location.href = this.settings.exitPath;
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
        self.startTimeout(self.settings.timeoutDuration);
        clearTimeout(self.respond);
      });
    }
  };

  moj.Modules.TimeoutPrompt = {
    init: function() {
      return $('.TimeoutPrompt').each(function() {
        $(this).data('TimeoutPrompt', new TimeoutPrompt($(this), $(this).data()));
      });
    }
  };

}());
