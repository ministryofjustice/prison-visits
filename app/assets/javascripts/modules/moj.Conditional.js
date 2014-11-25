/* globals $ */

(function () {
  'use strict';

  moj.Modules.Conditional = {
    el: '.js-Conditional',

    init: function () {
      this.cacheEls();
      this.bindEvents();
    },

    bindEvents: function () {
      this.$conditionals.on('change deselect', this.toggle);
      moj.Events.on('render', $.proxy(this.render, this));
    },

    cacheEls: function () {
      this.$conditionals = $(this.el);
    },

    render: function () {
      this.$conditionals.each(this.toggle);
    },

    toggle: function (e) {
      var $el = $(this),
          $conditionalEl = moj.Modules.Conditional.conditionals($el.data('conditionalEl')),
          $conditionalAlt = moj.Modules.Conditional.conditionals($el.data('conditionalAlt'));

      // trigger a deselect event if a change event occured
      if (e.type === 'change') {
        $('input[name="' + $el.attr('name') + '"]').not($el).trigger('deselect');
      }

      // if a conditional element has been set, run the checks
      if ($el.data('conditionalEl')) {
        $el.attr('aria-control', $el.data('conditionalEl'));

        // if checked show/hide the extra content
        if(moj.Modules.Conditional.isCurrentOrListSelected($el, $el.data('conditionalVal'))){
          $conditionalEl.show();
          $conditionalAlt.hide();
          $conditionalEl.attr('aria-expanded', 'true').attr('aria-hidden', 'false');
        } else {
          $conditionalEl.hide();
          $conditionalAlt.show();
          $conditionalEl.attr('aria-expanded', 'false').attr('aria-hidden', 'true');
        }
      }
    },

    conditionals: function(string) {
      return $(string ? '#' + string.split(',').join(',#') : null);
    },

    isCurrentOrListSelected: function($el, list) {
      return $el.is(':checked') || (list && !!~list.indexOf($('[name="' + $el.attr('name') + '"]:checked').val()));
    }
  };
}());
