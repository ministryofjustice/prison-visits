# jslint browser: true, evil: false, plusplus: true, white: true, indent: 2, nomen: true 

# global moj, $ 

# SlotPicker modules for MOJ
# Dependencies: moj, jQuery

"use strict"

# Define the class
SlotPicker = (el, options) ->
  @settings = $.extend {}, @defaults, options
  @cacheEls el
  @bindEvents()
  @markChosenSlots window.current_slots
  @initCalendar()
  return @

SlotPicker:: =
  defaults:
    optionlimit: 3
    selections: 'has-selections'
    currentSlots: []

  cacheEls: ->
    @$wrapper = $ '#wrapper'
    @$slotInputs = $ '.js-slotpicker-slot'
    @$slotOptions = $ '.js-slotpicker-option'
    @$selectedSlots = $ '.selected-slots li'
    @$removeSlots = '.js-remove-slot'
    @$promoteSlots = '.js-promote-slot'
    @$calendar = $ '#calendar'

  bindEvents: ->
    # store a reference to obj before 'this' becomes jQuery obj
    _this = this
    
    @$slotOptions.on 'click', (e) ->
      _this.emptyUiSlots()
      _this.emptySlotInputs()
      _this.unHighlightSlots()
      _this.checkSlot $(this)
      _this.processSlots()
      _this.disableCheckboxes _this.limitReached()

    @$wrapper.on 'click', @$removeSlots, (e) ->
      e.preventDefault()
      $( $(this).data('slot-option') ).click()

    @$wrapper.on 'click', @$promoteSlots, (e) ->
      e.preventDefault()
      _this.promoteSlot $(this).attr('href').split('#')[1] - 1
      _this.processSlots()

  markChosenSlots: (slots) ->
    for slot in slots
      $("[value='#{slot}']").click()

  highlightSlot: (slot) ->
    slot.addClass 'is-active'
  
  unHighlightSlots: ->
    $('.js-slotpicker-options label').removeClass 'is-active'

  emptyUiSlots: ->
    slots = @$selectedSlots
    slots.removeClass 'is-active'
    slots.find('a').removeData()
    slots.find('.date, .time').text ''

  emptySlotInputs: ->
    @$slotInputs.find('select').val ''

  populateUiSlots: (index, checkbox) ->
    date = @splitDateAndSlot(checkbox.val())[0]

    label = checkbox.closest('label')
    day = label.siblings('h4').text()
    time = label.find('strong').text()
    duration = label.find('.duration').text()
    
    $slot = @$selectedSlots.eq(index)

    $slot.addClass 'is-active'
    $slot.find('.date').text day
    $slot.find('.time').text [time, duration].join(', ')
    # store reference to checkbox
    $slot.find('.js-remove-slot').data 'slot-option', checkbox

  populateSlotInputs: (index, chosen) ->
    @$slotInputs.eq(index).find('[name="visit[slots][][slot]"]').val chosen

  processSlots: ->
    _this = this
    i = 0

    for slot in @settings.currentSlots
      $slotEl = $ "[value=#{slot}]"

      _this.highlightSlot $slotEl.closest('label')
      _this.populateSlotInputs i, $slotEl.val()
      _this.populateUiSlots i, $slotEl
      
      i++

  limitReached: ->
    @$slotOptions.filter(':checked').length >= @settings.optionlimit

  disableCheckboxes: (disable) ->
    @$slotOptions.not(':checked').prop 'disabled', disable
    @$slotOptions.not(':checked').closest('label')[if disable then 'addClass' else 'removeClass'] 'is-disabled'

  splitDateAndSlot: (str) ->
    bits = str.split '-'
    time = bits.splice(-2).join '-'
    [bits.join('-'),time]

  checkSlot: (el) ->
    if el.is(':checked')
      @addSlot el.val()
    else
      @removeSlot el.val()

  addSlot: (slot) ->
    @settings.currentSlots.push slot
    @highlightDay slot

  removeSlot: (slot) ->
    pos = @settings.currentSlots.indexOf slot
    @settings.currentSlots.splice pos, 1
    @highlightDay slot

  promoteSlot: (pos) ->
    @settings.currentSlots = @settings.currentSlots.move pos, pos-1

  highlightDay: (slot) ->
    day = @splitDateAndSlot(slot)[0]
    $("[data-date=#{day}]")[if ~@settings.currentSlots.join('-').indexOf(day) then 'addClass' else 'removeClass'] 'fc-chosen'

  refreshCal: ->
    @$calendar.fullCalendar 'render'

  initCalendar: ->
    _this = @

    # Fullcalendar
    @$calendar.fullCalendar
      header:
        left: 'prev'
        center: 'title'
        right: 'next'

      viewRender: (view, element) ->
        $('#calendar').find('.fc-day').not('.fc-unbookable').first().click()

      dayClick: (date, allDay, jsEvent, view) ->
        $day = $( jsEvent.target ).closest( '.fc-day' )

        # Show the slots for the selected day
        $('.js-slotpicker-options').removeClass 'is-active'
        $("#date-#{date.formatIso()}").addClass 'is-active'

        # Show unbookable day message
        unless ~window.bookable_dates.indexOf date.formatIso()
          today = new Date((new Date()).formatIso())
          bookingFrom = new Date(window.bookable_from)
          if date < today
            $('#in-the-past').addClass 'is-active'
          if date >= today
            if date > bookingFrom
              $('#too-far-ahead').addClass 'is-active'
            else
              $('#booking-gap').addClass 'is-active'

        # Highlight the currently selected day on the calendar
        $('.fc-day').removeClass('fc-state-highlight')
        $day.addClass('fc-state-highlight')

      dayRender: (date, cell) ->
        # mark days which cannot be booked
        unless ~window.bookable_dates.indexOf date.formatIso()
          cell.addClass 'fc-unbookable'

        # mark days where there a no visit slots
        unless ~window.bookable_days.indexOf date.getDay()
          cell.addClass 'fc-unbookable'

        # mark days which contain currently selected slots
        for slot in _this.settings.currentSlots
          cell.addClass 'fc-chosen' if _this.splitDateAndSlot(slot)[0] is date.formatIso()

# Add module to MOJ namespace
moj.Modules.slotPicker = init: ->
  $('.js-slotpicker').each ->
    $(this).data 'slotpicker', new SlotPicker($(this), $(this).data())
