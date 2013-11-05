casper.test.on 'fail', ->
  casper.capture 'tests/failure.png'

casper.test.begin 'Prison Visit Booking: Step 1 ', (test) ->

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
    @capture 'tests/step1_valid.png'

  casper.then ->
    test.comment 'Prison Visit Booking: Step 2'

  casper.then ->
    test.assertVisible '#visit_visitor__first_name'

  casper.then ->
    @fillSelectors '#new_visit',
      '.js-dob__day': '24'
      '.js-dob__month': '06'
      '.js-dob__year': '1975'
    , false

    test.assertEvalEquals ->
      __utils__.findOne('#visitor_date_of_birth_0').value
    , '1975-06-24', 'JS form fields have changed the user DOB'

    @fill '#new_visit',
      'visit[visitor][][first_name]': 'Sue'
      'visit[visitor][][last_name]': 'Denim'
      'visit[visitor][][email]': 'sue@denim.com'
      'visit[visitor][][phone]': '0123 456 789'
    , false

  casper.then ->
    @click '#continue'

  casper.then ->
    test.assertUrlMatch /localhost:3000\/4/, 'we should have progressed to step three'

  casper.then ->
    @capture 'tests/step2_valid.png'

  casper.run ->
    test.done()