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
      'prisoner[date_of_birth(1i)]': ''
      'prisoner[date_of_birth(2i)]': ''
      'prisoner[date_of_birth(3i)]': ''
      'prisoner[number]': ''
      'prisoner[prison_name]': ''
    , true

  casper.then ->
    test.assertSelectorHasText '[for="prisoner_first_name"] .validation-message', "can't be blank", 'page contains name error'
    test.assertSelectorHasText '[for="prisoner_date_of_birth_3i"] .validation-message', "can't be blank", 'page contains age error'
    test.assertSelectorHasText '[for="prisoner_number"] .validation-message', 'must be a valid prisoner number', 'page contains prisoner number error'
    test.assertSelectorHasText '[for="prisoner_prison_name"] .validation-message', 'must be chosen', 'page contains prisoner number error'

  casper.then ->
    casper.capture 'tests/prisoner_details_invalid.png' if outputImages

  casper.run ->
    test.done()
