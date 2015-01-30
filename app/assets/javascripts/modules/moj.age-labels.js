(function () {

  'use strict';

  moj.Modules.ageLabels = {

    init: function() {

      function getAge(d1, d2) {
        d2 = d2 || new Date();
        var diff = d2.getTime() - d1.getTime();
        return Math.floor(diff / (1000 * 60 * 60 * 24 * 365.25));
      }

      // Display adult/child labels against visitors when entering DOB
      $('body').on('change', '.known-date input', function() {

        var dob, el,
            known = $(this).closest('.known-date'),
            year = known.find('.year').val(),
            month = known.find('.month').val(),
            day = known.find('.day').val();

        el = $(this).closest('.additional-visitor').find('h2');

        if (year!=='' && month !== '' && day !== '') {
          dob = new Date(year, month-1, day);

          el.find('small').remove();

          if (getAge(dob) > 17) {
            el.append(' <small class="adult">Adult</small>');
          } else {
            el.append(' <small class="child">Child</small>');
          }
        }
      });

      $('.known-date input').change();

    }

  }

}());
