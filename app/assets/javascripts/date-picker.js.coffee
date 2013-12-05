field = $('.js-dob')

field.find('.js-dob__input').addClass 'visible--mobile'

field.find('.js-dob__dropdowns').removeClass('hidden').addClass 'hidden--mobile'

field.on 'change', '.js-dob__select', ->
  dob = $(this).closest '.js-dob'

  day = dob.find '.js-dob__day'
  month = dob.find '.js-dob__month'
  year = dob.find '.js-dob__year'

  $(this).closest('.js-dob').find('.js-dob__input').val "#{year.val()}-#{month.val()}-#{day.val()}"



pad = (num) ->
  ("00#{num}").slice -2



if Modernizr.inputtypes.date

  nativeDate = $('.js-native-date')

  nativeDate.each ->

    del = '-'
    input = $(this).find '.js-native-date__date-input'
    # label = input.siblings 'label'
    selects = nativeDate.find 'select'

    input.removeClass('hidden').addClass 'visible--mobile'
    selects.addClass 'hidden--mobile'

    selects.on 'change', ->

      year = selects.closest('.year').val()
      month = pad selects.closest('.month').val()
      day = pad selects.closest('.day').val()

      input.val [year,month,day].join(del)

    input.on 'change', ->
      
      dateParts = $(this).val().split del
      
      month = parseInt dateParts[1]
      day = parseInt dateParts[2]

      selects.closest('.year').val dateParts[0]
      selects.closest('.month').val (if isNaN(month) then '' else month)
      selects.closest('.day').val (if isNaN(day) then '' else day)

    selects.first().change() if selects.closest('.year').val() isnt ''
