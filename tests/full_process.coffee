casper.test.on 'fail', ->
  casper.capture 'tests/failure.png'

outputImages = if casper.cli.get('images') is 'on' then true else false

casper.test.begin 'Prison Visit Booking: Step 1 - prisoner details', (test) ->

  casper.start 'http://localhost:3000'

  casper.viewport 1024, 768

  casper.then ->
    @fillSelectors '#new_prisoner',
      '.js-native-date__date-input': '1977-02-18'
    , false

    @evaluate ->
      $('.js-native-date__date-input').trigger 'change'

  casper.then ->
    test.assertField 'prisoner[date_of_birth(3i)]', '18'
    test.assertField 'prisoner[date_of_birth(2i)]', '2'
    test.assertField 'prisoner[date_of_birth(1i)]', '1977'

    @fill '#new_prisoner',
      'prisoner[first_name]': 'Jimmy'
      'prisoner[last_name]': 'Fingers'
      'prisoner[number]': 'a1234bc'
      'prisoner[prison_name]': 'Gartree'
    , false

    @capture 'tests/prisoner_details_valid.png' if outputImages

  casper.then ->
    @click '.button-primary'

  casper.then ->
    test.assertUrlMatch /localhost:3000\/visitor-details/, 'we should have progressed to visitors'

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

    @capture 'tests/visitor_details_valid.png' if outputImages

  casper.then ->
    @click '.button-primary'

  casper.then ->
    test.assertUrlMatch /localhost:3000\/choose-date-and-time/, 'we should have progressed to choose date and time'

    test.comment 'Prison Visit Booking: Step 3 - choose a session'

    @click '.fc-bookable'
    @click '.day-slots.is-active label'

    @capture 'tests/choose-date-and-time.png' if outputImages

  casper.then ->
    @clickLabel 'Continue'

  casper.then ->
    test.assertUrlMatch /localhost:3000\/check-your-request/, 'we should have progressed to check your request'

  casper.then ->
    test.comment 'Prison Visit Booking: Step 4 - check your request'
    test.assertTextExists 'Jimmy Fingers', 'prisoner name is present'
    test.assertTextExists 'Sue Denim', 'user name is present'

    @capture 'tests/check-your-request.png' if outputImages

  casper.then ->
    @click '.button-primary'

  casper.then ->
    test.assertUrlMatch /localhost:3000\/request-sent/, 'we should have progressed to request confirmation'

    @capture 'tests/request_sent.png' if outputImages

  casper.run ->
    test.done()