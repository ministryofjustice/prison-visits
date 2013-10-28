casper.test.on 'fail', ->
  casper.capture 'tests/failure.png'

casper.test.begin 'Prison Visit Booking: Step 1 valid', (test) ->

  casper.start 'http://localhost:3000'

  casper.viewport 1024, 768

  casper.then ->
    @fillSelectors '#new_prisoner',
      '.js-dob__day': '18'
      '.js-dob__month': '02'
      '.js-dob__year': '1977'
    , false

    test.assertField 'prisoner[date_of_birth]', '1977-02-18'

    @fill '#new_prisoner',
      'prisoner[first_name]': 'Jimmy'
      'prisoner[last_name]': 'Fingers'
      'prisoner[number]': 'a1234bc'
      'prisoner[prison_name]': 'Gartree'
    , true

  casper.then ->
    test.assertUrlMatch /localhost:3000\/2/, 'we should have progressed to step two'

  casper.then ->
    casper.capture 'tests/step1_valid.png'

  casper.run ->
    test.done()