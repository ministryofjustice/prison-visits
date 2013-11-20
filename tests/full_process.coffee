casper.test.on 'fail', ->
  casper.capture 'tests/failure.png'

outputImages = if casper.cli.get('images') is 'on' then true else false

casper.test.begin 'Prison Visit Booking: Step 1 - prisoner details', (test) ->

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
    , false

    @capture 'tests/step1_valid.png' if outputImages

  casper.then ->
    @click '.button-primary'

  casper.then ->
    test.assertUrlMatch /localhost:3000\/2/, 'we should have progressed to visitors'

    test.comment 'Prison Visit Booking: Step 2 - visitors'

    test.assertVisible '#visit_visitor__first_name'

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

    @capture 'tests/step2_valid.png' if outputImages

  casper.then ->
    @clickLabel 'Continue'

  casper.then ->
    test.assertUrlMatch /localhost:3000\/4/, 'we should have progressed to session chooser'

    test.comment 'Prison Visit Booking: Step 3 - choose a session'

    @click '.fc-bookable'
    @click '.day-slots.is-active label'

    @capture 'tests/step3_valid.png' if outputImages

  casper.then ->
    @clickLabel 'Continue'

  casper.then ->
    test.assertUrlMatch /localhost:3000\/5/, 'we should have progressed to summary'

  casper.then ->
    test.comment 'Prison Visit Booking: Step 4 - summary'
    test.assertTextExists 'Jimmy Fingers', 'prisoner name is present'
    test.assertTextExists 'Sue Denim', 'user name is present'

    @capture 'tests/step4.png' if outputImages

  casper.then ->
    @click '.button-primary'

  casper.then ->
    test.assertUrlMatch /localhost:3000\/6/, 'we should have progressed to request confirmation'

    @capture 'tests/step5.png' if outputImages

  casper.run ->
    test.done()