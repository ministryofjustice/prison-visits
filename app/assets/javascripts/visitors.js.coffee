# Disable the add visitor button
$('button[value=add]').prop 'disabled', true


addVisitorBlocks = (amount) ->
  i = 0
  while i < amount
    compiled = _.template($('#additional-visitor').html())
    $compiled = $(compiled())
    $('.additional-visitors').append setPosition($compiled)
    i++


removeVisitorBlocks = (amount) ->
  v = $('.visitor')
  r = v.length - amount

  v.filter( (i) ->
    true if i >= r
  ).remove()


countVisitors = ->
  $('.additional-visitor').length


setPosition = ($el) ->
  count = countVisitors()
  $el.find('.js-visitor-position').text count+2
  $el


$('.number_of_visitors').on 'change', ->
  desired = $(this).val()
  current = countVisitors()

  # add visitors blocks if the desired amount is more than is currently in the form
  if desired > current
    addVisitorBlocks desired-current
  # leave as is if the desired amount is the same as currently available
  # remove visitor blocks if the form currently contains more that desired
  else removeVisitorBlocks(current-desired) if desired < current
