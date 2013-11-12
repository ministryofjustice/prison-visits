field = $('.js-dob')

field.find('.js-dob__input').addClass 'visible--mobile'

field.find('.js-dob__dropdowns').removeClass('hidden').addClass 'hidden--mobile'

field.on 'change', '.js-dob__select', ->
  dob = $(this).closest '.js-dob'

  day = dob.find '.js-dob__day'
  month = dob.find '.js-dob__month'
  year = dob.find '.js-dob__year'

  $(this).closest('.js-dob').find('.js-dob__input').val "#{year.val()}-#{month.val()}-#{day.val()}"