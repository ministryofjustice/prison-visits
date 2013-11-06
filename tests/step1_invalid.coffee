casper.test.on 'fail', ->
  casper.capture 'tests/failure.png'

outputImages = if casper.cli.get('images') is 'on' then true else false

casper.test.begin 'Prison Visit Booking: Step 1 invalid', (test) ->

  casper.start 'http://localhost:3000'

  casper.viewport 1024, 768

  casper.then ->
    @fill '#new_prisoner',
      'prisoner[first_name]': ''
      'prisoner[last_name]': ''
      'prisoner[date_of_birth]': ''
      'prisoner[number]': ''
      'prisoner[prison_name]': ''
    , true

  casper.then ->
    test.assertTextExists "can't be blank", 'page contains name error'
    test.assertTextExists 'must be within last 100 years', 'page contains age range error'
    test.assertTextExists 'must be a valid prisoner number', 'page contains prisoner number error'

  casper.then ->
    casper.capture 'tests/step1_invalid.png' if outputImages

  casper.run ->
    test.done()