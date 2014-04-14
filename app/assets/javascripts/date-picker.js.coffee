pad = (num) ->
  ("00#{num}").slice -2


moj.useNativeDate = Modernizr.inputtypes.date and Modernizr.touch

moj.showNativeDate = (form) ->
  if moj.useNativeDate
    nativeDate = form.find '.js-native-date'

    nativeDate.find('.js-native-date__date-input').removeClass 'hidden'
    nativeDate.find('select').addClass 'hidden'


$ ->

  del = '-'

  $(document).on 'change', '.js-native-date select', ->

    input = $(this).closest('.js-native-date').find '.js-native-date__date-input'
    selects = $(this).siblings('select').add $(this)

    year = selects.closest('.year').val()
    month = pad selects.closest('.month').val()
    day = pad selects.closest('.day').val()

    input.val [year,month,day].join(del)

  $(document).on 'change', '.js-native-date__date-input', ->

    selects = $(this).closest('.js-native-date').find 'select'
    
    dateParts = $(this).val().split del
    
    month = parseInt dateParts[1]
    day = parseInt dateParts[2]

    selects.closest('.year').val dateParts[0]
    selects.closest('.month').val (if isNaN(month) then '' else month)
    selects.closest('.day').val (if isNaN(day) then '' else day)

  moj.showNativeDate $('form')

  selects = $('.js-native-date select:first-of-type')
  selects.change() if selects.closest('.year').val() isnt ''
