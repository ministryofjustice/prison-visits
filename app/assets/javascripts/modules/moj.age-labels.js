// Age labels for MOJ
// Dependancies: moj, jQuery

(function () {

  'use strict';

  var AgeLabels = function($el, options) {
    this.init($el, options);
    return this;
  };

  AgeLabels.prototype = {

    defaults: {
      threshold: 18,
      dateFields: '.known-date',
      toLabel: 'h2'
    },

    init: function($el, options) {
      this.settings = $.extend({}, this.defaults, options);
      this.cacheEls($el);
      this.bindEvents();
      this.showLabel();
    },

    cacheEls: function($el) {
      this.$el = $el;
      this.$dateFields = this.$el.find(this.settings.dateFields);
      this.$toLabel = this.$el.find(this.settings.toLabel);
    },

    bindEvents: function() {
      this.$dateFields.on('change', 'input', $.proxy(this.showLabel, this));
    },

    showLabel: function() {

      var dateFields, type,
          year = this.$dateFields.find('.year').val(),
          month = this.$dateFields.find('.month').val(),
          day = this.$dateFields.find('.day').val();

      if (year!=='' && month !== '' && day !== '') {
        dateFields = new Date(year, month-1, day);

        this.$toLabel.find('small').remove();

        if (this.getAge(dateFields) >= this.settings.threshold) {
          type = 'Adult';
        } else {
          type = 'Child';
        }

        this.$toLabel.append(' <small class="' + type.toLowerCase() + '">' + type + '</small>');
      }

    },

    getAge: function(d1, d2) {
      d2 = d2 || new Date();
      var diff = d2.getTime() - d1.getTime();
      return Math.floor(diff / (1000 * 60 * 60 * 24 * 365.25));
    }

  };

  moj.Modules.AgeLabels = AgeLabels;

}());
