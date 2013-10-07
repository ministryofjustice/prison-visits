$('.js-date-picker').change ->
  day = $ '#prisoner_dob_day'
  month = $ '#prisoner_dob_month'
  year = $ '#prisoner_dob_year'

  dob = "#{year.val()}-#{month.val()}-#{day.val()}"
  console.log dob
  $('#prisoner_date_of_birth').val dob