/* globals $ */

(function () {
  'use strict';

  var CheckboxSummary = function($el, options) {
    this.init($el, options);
    return this;
  };

  CheckboxSummary.prototype = {
    init: function ($el, options) {
      this.cacheEls($el);
      this.bindEvents();
      this.settings = $.extend({}, {
        glue: ', ',
        strip: ';',
        sub: ' '
      }, options);
      this.settings.original = this.$summaries.first().text() || '[summary]';
    },

    bindEvents: function () {
      this.$checkboxes.on('change deselect', $.proxy(this.summarise, this));
      moj.Events.on('render', $.proxy(this.render, this));
    },

    cacheEls: function ($el) {
      this.$el = $el;
      this.$checkboxes = $el.find('[type=checkbox]');
      this.$summaries = $el.find('.CheckboxSummary-summary');
    },

    render: function () {
      this.$checkboxes.each($.proxy(this.summarise, this));
    },

    getChecked: function () {
      return this.$checkboxes.filter(function() {
        return $(this).is(':checked');
      })
    },

    stripChars: function(string) {
      var reg = new RegExp('[' + this.settings.strip + ']', 'ig');
      return string.replace(reg, this.settings.sub);
    },

    summarise: function () {
      var $el = $(this),
          summary = [],
          text = '',
          checked = this.getChecked();

      checked.each(function() {
        summary.push($(this).val());
      });

      if (summary.length) {
        text = this.stripChars(summary.join(this.settings.glue))
      } else {
        text = this.settings.original
      }

      this.$summaries.text(text);
    }
  };

  moj.Modules.CheckboxSummary = {
    init: function() {
      return $('.CheckboxSummary').each(function() {
        $(this).data('CheckboxSummary', new CheckboxSummary($(this), $(this).data()));
      });
    }
  };
}());
