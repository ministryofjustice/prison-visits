/*jslint browser: true, evil: false, plusplus: true, white: true, indent: 2, nomen: true */
/*global moj, $ */

// Tabs modules for MOJ
// Dependencies: moj, jQuery

// TODO
// done - focus on first focusable element
// done - allow nesting
// allow options
// optional: focus first link
// optional: activate first tab
// activate anchor link

(function(){

  "use strict";

  // Define the class
  var Tabs = function (el) {
    this._cacheEls(el);
    this._bindEvents();
    this._activateFirstLink();
  };

  Tabs.prototype = {

    classes: {
      active:'is-active'
    },

    _activateFirstLink: function () {
      // activate first tab
      this.$tabNav.find('li').first().find('a').click();
    },

    _cacheEls: function (wrap) {
      this.$tabNav = $('ul', wrap).first();
      this.$tabs = $('a', this.$tabNav);
      this.$tabPanes = $('.js-tabs-content', wrap).first().children();
    },

    _bindEvents: function () {
      // store a reference to obj before 'this' becomes jQuery obj
      var self = this;

      this.$tabs.on('click', function (e) {
        e.preventDefault();
        self._activateLink($(this));
        self._activateTab($(this).attr('href'));
      });
    },

    _activateLink: function (el) {
     this.$tabs.removeClass(this.classes.active).filter(el).addClass(this.classes.active);
    },

    _activateTab: function (hash) {
      var shown = this.$tabPanes.hide().filter(hash).show();
      this._focusFirstElement(shown);
    },

    _focusFirstElement: function (el) {
      el.find('a, input, textarea, select, button, [tabindex]').not(':disabled').first().focus();
    }

  };

  // Add module to MOJ namespace
  moj.Modules.tabs = {
    init: function () {
      $('.js-tabs').each(function () {
        $(this).data('moj.tabs', new Tabs($(this)));
      });
    }
  };

}());