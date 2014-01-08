
scrolls = $ '.scroll'
large = $ '#large-dates'
small = $ '#small-dates'
touch = $ '#touch'

currentPos = 0
leadDays = 3
displayDays = 7
daySize = 100
inactive = 300
animateSpeed = 250


getPos = (el) ->
  el.scrollLeft()


differentPos = (pos) ->
  if currentPos isnt pos
    currentPos = pos
    true


slide = (pos) ->
  scrolls.animate(
    scrollLeft: pos
  , animateSpeed).promise().done ->
    large.trigger 'moved'


getDateFromIndex = (index) ->
  large.find('.day').eq(index).data 'date'


posOfDateAt = (x) ->
  width = touch.width()
  dayWidth = width / displayDays
  target = Math.floor(x / dayWidth) # zero based
  center = Math.floor(displayDays / 2)
  goto = if target < center then -(center - target) else target - center
  goto * dayWidth


posOfNearestDateTo = (x) ->
  balance = x % daySize
  if balance > daySize / 2 then x - balance + daySize else x - balance


syncScrollPos = (el) ->
  el.siblings('.scroll').scrollLeft el.scrollLeft()


centreDateWhenInactive = (obj) ->
  clearTimeout $.data(obj, 'scrollTimer')
  $.data(obj, 'scrollTimer', setTimeout ->
    slide posOfNearestDateTo(getPos(large))
  , inactive)


touch.on
  'scroll': ->
    syncScrollPos touch

  'click': (e) ->
    slide posOfDateAt(e.offsetX)


large.on
  'moved': ->
    if differentPos getPos(large)
      moj.log getDateFromIndex(currentPos / daySize)

  'scroll': ->
    centreDateWhenInactive this
