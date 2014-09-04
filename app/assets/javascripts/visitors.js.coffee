# Disable the add visitor button
$('#add-visitor').remove()


addVisitorBlocks = (amount) ->
  i = 1
  while i < amount + 1
    compiled = Handlebars.compile $('#additional-visitor').html()
    $compiled = $(compiled({index: countVisitors() + 1}))
    $('.additional-visitors').append ($compiled)
    i++
  updatePositions()


removeVisitorBlocks = (amount) ->
  v = $('.visitor')
  r = v.length - amount

  v.filter( (i) ->
    true if i >= r
  ).remove()


countVisitors = ->
  $('.additional-visitor').length


updateOption = (num) ->
  $('.number_of_visitors').val countVisitors()


updatePositions = ->
  $('.additional-visitor').each (i) ->
    $(this).find('.js-visitor-position').text i+2


$('.number_of_visitors').on 'change', ->
  desired = $(this).val()
  current = countVisitors()

  # add visitors blocks if the desired amount is more than is currently in the form
  if desired > current
    addVisitorBlocks desired-current
  # leave as is if the desired amount is the same as currently available
  # remove visitor blocks if the form currently contains more that desired
  else removeVisitorBlocks(current-desired) if desired < current


$('body').on 'click', '.remove-link', (e) ->
  e.preventDefault()
  $(this).closest('.additional-visitor').remove()
  updatePositions()
  updateOption()
