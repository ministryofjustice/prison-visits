$('.js-date-picker').change ->
  day = $ '#prisoner_dob_day'
  month = $ '#prisoner_dob_month'
  year = $ '#prisoner_dob_year'

  dob = "#{year.val()}-#{month.val()}-#{day.val()}"
  $('#prisoner_date_of_birth').val dob

$('.js-dob').on 'change', '.js-dob__select', ->
  dob = $(this).closest '.js-dob'

  day = dob.find '.js-dob__day'
  month = dob.find '.js-dob__month'
  year = dob.find '.js-dob__year'

  $(this).closest('.js-dob').find('.js-dob__input').val "#{year.val()}-#{month.val()}-#{day.val()}"