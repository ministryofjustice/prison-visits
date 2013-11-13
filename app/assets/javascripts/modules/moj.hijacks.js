/*jslint browser: true, evil: false, plusplus: true, white: true, indent: 2, nomen: true */
/*global moj, $ */

// General utilities for MOJ
// Dependencies: moj, jQuery

(function(){

  "use strict";

  moj.Modules.hijacks = {
    init: function () {

      $('body')
      
        // Open browser print dialog
        .on('click', '.print-link', function (e) {
          e.preventDefault();
          window.print();
        })

        // Open external links in a new window (add rel="ext" to the link)
        .on('click', 'a[rel*=ext], a[rel*=help]', function (e) {
          e.preventDefault();
          window.open($(this).attr('href'));
        });
    }
  };

}());