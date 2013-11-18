# Disable the add visitor button
$('button[value=add]').prop 'disabled', true


addVisitorBlocks = (amount, type) ->
  i = 0
  while i < amount
    compiled = _.template($('#additional-visitor').html())
    $compiled = $(compiled()).addClass type
    $(".additional-#{type}").append setType($compiled, type, i)
    i++


removeVisitorBlocks = (amount, type) ->
  v = $(".#{type}")
  r = v.length - amount

  v.filter( (i) ->
    true if i >= r
  ).remove()


setType = ($el, type, i) ->
  positions = ['first','second','third','forth','fifth']
  $el.find('.js-visitor-position').text positions[i]
  $el.find('.js-visitor-type').text type
  $el.find('.visitor-type').val type
  $el


$('.number_of_visitors').on 'change', ->
  type = if $(this).hasClass('adults') then 'adult' else 'child'
  desired = $(this).val()
  current = $('.visitor').filter(".#{type}").length

  # add visitors blocks if the desired amount is more than is currently in the form
  if desired > current
    addVisitorBlocks desired-current, type
  # leave as is if the desired amount is the same as currently available
  # remove visitor blocks if the form currently contains more that desired
  else removeVisitorBlocks(current-desired, type) if desired < current
