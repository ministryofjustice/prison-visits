# jslint browser: true, evil: false, plusplus: true, white: true, indent: 2, nomen: true, jquery: true

# global moj

# Touch date slider module for MOJ
# Dependencies: moj, jQuery

"use strict"

DateSlider = ($el, options) ->
  @settings = $.extend {}, @defaults, options
  @cacheEls $el
  @bindEvents()
  @gather()
  @sizeUp()
  @inputDevice()
  @selectDateFromIndex 0 if @settings.selectonload
  return @

DateSlider:: =
  defaults:
    currentPos: 0
    visibleDays: 12
    displayDays: 7
    selectableDays: 6
    width: 700
    dayWidth: 100
    middle: 300
    inactive: 300
    animateSpeed: 250
    selectonload: false

  cacheEls: ($el) ->
    @$_el = $el

    @$window = $ window
    @$scrolls = $ '.scroll', $el
    @$large = $ '.DateSlider-largeDates', $el
    @$touch = $ '.DateSlider-touch', $el
    @$months = $ '.DateSlider-month span', $el
    @$buttonL = $ '.DateSlider-buttonLeft', $el
    @$buttonR = $ '.DateSlider-buttonRight', $el

    # needed for CSS changes
    @$sliders = $ '.DateSlider-sliders', $el
    @$small = $ '.DateSlider-smallDates', $el
    @$frame = $ '.DateSlider-portalFrame', $el
    @$day = $ 'li', $el
    @$largeRow = $ '.DateSlider-days', @$large
    @$smallRow = $ '.DateSlider-days', @$small
    @$touchRow = $ '.DateSlider-days', @$touch
    @$largeRowDay = $ 'li', @$largeRow
    @$largeRowSmall = $ 'small', @$largeRow


  bindEvents: ->
    @$touch.on
      'scroll': => @syncScrollPos @$touch

      'click': (e) => @slide @posOfDateAt(e.offsetX)


    @$large.on
      'chosen': =>
        if @differentPos @$large.scrollLeft()
          @selectDateFromIndex(@settings.currentPos / @settings.dayWidth)

      'scroll': => @centreDateWhenInactive @

    @$window.on 'resize', =>
      @sizeUp()
      @centreDateWhenInactive @

    @$buttonL.on 'click', (e) =>
      e.preventDefault()
      @slide @settings.currentPos - @settings.dayWidth

    @$buttonR.on 'click', (e) =>
      e.preventDefault()
      @slide @settings.currentPos + @settings.dayWidth


  gather: ->
    @settings.visibleDays = @$small.find('li').length
    @settings.selectableDays = @$large.find('li').length


  sizeUp: ->
    squashDays = 0.95
    magnifyDay = 1.4
    upness = 0.22
    fontSizeScale = 0.52
    magnifyFont = 1.33
    shrinkWeekday = 0.42
    borderWidth = 2

    viewPort = @$window.width()

    @settings.dayWidth = Math.floor(viewPort / @settings.displayDays)
    @settings.width = @settings.dayWidth * @settings.displayDays
    @settings.middle = Math.floor(@settings.displayDays / 2) * @settings.dayWidth
    
    dayHeight = Math.floor @settings.dayWidth * squashDays
    largeHeight = Math.floor dayHeight * magnifyDay
    largeLineHeight = (largeHeight * upness) * 2 + dayHeight
    
    fontSmall = dayHeight * fontSizeScale
    fontLarge = fontSmall * magnifyFont
    fontSmaller = fontLarge * shrinkWeekday

    @$buttonL.add(@$buttonR).css
      width: "#{@settings.dayWidth}px"
      height: "#{dayHeight}px"
      fontSize: "#{fontLarge}px"
      lineHeight: "#{dayHeight}px"

    @$sliders.css height: "#{dayHeight}px"

    @$day.css
      width: "#{@settings.dayWidth}px"
      fontSize: "#{fontSmall}px"
      lineHeight: "#{dayHeight}px"
    
    @$touchRow.css width: "#{@settings.dayWidth * @settings.visibleDays}px"
    
    @$smallRow.css width: "#{@settings.dayWidth * @settings.visibleDays}px"

    @$largeRow.css width: "#{@settings.dayWidth * @settings.selectableDays}px"
    
    @$largeRowDay.css
      fontSize: "#{fontLarge}px"
      lineHeight: "#{largeLineHeight}px"
    
    @$largeRowSmall.css fontSize: "#{fontSmaller}px"

    @$scrolls.css width: "#{viewPort}px"

    @$large.css
      height: "#{largeHeight}px"
      width: "#{@settings.dayWidth}px"
      top: "-#{Math.floor(largeHeight * upness) - borderWidth}px"
      left: "#{@settings.middle}px"
    
    @$frame.css
      width: "#{@settings.dayWidth - borderWidth}px"
      height: "#{largeHeight}px"
      top: "-#{Math.floor largeHeight * upness}px"
      left: "#{@settings.middle - borderWidth / 2}px"

    @$_el.css visibility: 'visible'


  inputDevice: -> (if Modernizr.touch then @$buttonL.add(@$buttonR) else @$touch).remove()


  differentPos: (pos) ->
    if @settings.currentPos isnt pos
      @settings.currentPos = pos
      true


  slide: (pos) ->
    @$scrolls.animate(
      scrollLeft: pos
    , @settings.animateSpeed).promise().done =>
      @$large.trigger 'chosen'


  selectDateFromIndex: (index) ->
    day = @$large.find('li').eq index
    day.trigger 'chosen'
    @showMonthForDate day.data('date')


  showMonthForDate: (dateStr) ->
    self = @
    @$months.addClass('hidden').filter(->
      $(@).data('date') is self.yearMonthFromDate dateStr
    ).removeClass 'hidden'


  yearMonthFromDate: (date) -> date.split('-').splice(0,2).join '-'


  posOfDateAt: (x) -> (Math.floor(x / @settings.dayWidth) * @settings.dayWidth) - @settings.middle


  posOfNearestDateTo: (x) ->
    balance = x % @settings.dayWidth
    if balance > @settings.dayWidth / 2 then x - balance + @settings.dayWidth else x - balance


  syncScrollPos: ($el) -> $el.siblings('.scroll').scrollLeft $el.scrollLeft()


  centreDateWhenInactive: (obj) ->
    clearTimeout $.data(obj, 'scrollTimer')
    $.data(obj, 'scrollTimer', setTimeout =>
      @slide @posOfNearestDateTo(@$large.scrollLeft())
    , @settings.inactive)


# Add module to MOJ namespace
moj.Modules.DateSlider = init: ->
  $('.DateSlider').each ->
    $(this).data 'DateSlider', new DateSlider($(this), $(this).data())
