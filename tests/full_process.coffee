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

  casper.then ->
    test.assertField 'prisoner[prison_name]', ''
    test.assertField 'prisoner[date_of_birth(3i)]', '18'
    test.assertField 'prisoner[date_of_birth(2i)]', '2'
    test.assertField 'prisoner[date_of_birth(1i)]', '1977'

    @fill '#new_prisoner',
      'prisoner[first_name]': 'Jimmy'
      'prisoner[last_name]': 'Harris'
      'prisoner[number]': 'a1234bc'
      'prisoner[prison_name]': 'Rochester'
    , false

    @capture 'tests/prisoner_details_valid.png' if outputImages

  casper.then ->
    @click '.button-primary'

  casper.then ->
    test.assertUrlMatch /localhost:3000\/visitor-details/, 'we should have progressed to visitors'

    test.comment 'Prison Visit Booking: Step 2 - visitors'

    test.assertVisible '#first_name_0'

    @fillSelectors '#new_visit',
      '.js-native-date__date-input': '1975-06-24'
    , false

  casper.then ->
    test.assertField 'visit[visitor][][date_of_birth(3i)]', '24'
    test.assertField 'visit[visitor][][date_of_birth(2i)]', '6'
    test.assertField 'visit[visitor][][date_of_birth(1i)]', '1975'

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

    @click '.BookingCalendar-day--bookable .BookingCalendar-dayLink'
    test.assertTextExists 'Choose a second date', 'slot help is present'
    
    @click '.day-slots.is-active input'

    @capture 'tests/choose-date-and-time.png' if outputImages

  casper.then ->
    @clickLabel 'Continue'

  casper.then ->
    test.assertUrlMatch /localhost:3000\/check-your-request/, 'we should have progressed to check your request'

  casper.then ->
    test.comment 'Prison Visit Booking: Step 4 - check your request'
    test.assertTextExists 'Jimmy Harris', 'prisoner name is present'
    test.assertTextExists 'Sue Denim', 'visitor name is present'

    @capture 'tests/check-your-request.png' if outputImages

  casper.then ->
    @click '.button-primary'

  casper.then ->
    test.assertUrlMatch /localhost:3000\/request-sent/, 'we should have progressed to request confirmation'

    @capture 'tests/request_sent.png' if outputImages

  casper.run ->
    test.done()
