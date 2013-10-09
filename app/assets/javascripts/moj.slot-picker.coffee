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
  @checkSlots window.slots

SlotPicker:: =
  defaults:
    optionlimit: 3
    selections: 'has-selections'

  cacheEls: ->
    @$wrapper = $ '#wrapper'
    @$slotInputs = $ '.js-slotpicker-chosen fieldset'
    @$slotOptions = $ '.js-slotpicker-option'
    @$slotDays = $ '.js-slotpicker-day'
    @$selectedSlots = $ '.selected-slots li'
    @removeSlots = '.js-remove-slot'

  bindEvents: ->
    # store a reference to obj before 'this' becomes jQuery obj
    _this = this
    
    @$slotOptions.on 'click', (e) ->
      _this._emptyUiSlots()
      _this._emptySlotInputs()
      _this.unHighlightSlots()
      _this._processSlots()
      _this._disableCheckboxes _this._limitReached()

    @$wrapper.on 'click', @removeSlots, (e) ->
      e.preventDefault()
      $( $(this).data('slot-option') ).click()

  checkSlots: (slots) ->
    for slot in slots
      $("[value='#{slot.date}-#{slot.times}']").click()

  highlightSlot: (slot) ->
    slot.addClass 'is-active'
  
  unHighlightSlots: ->
    $('.js-slotpicker-options label').removeClass 'is-active'

  _emptyUiSlots: ->
    slots = @$selectedSlots
    slots.removeClass 'is-active'
    slots.find('a').removeData()
    slots.find('.date, .time').text ''

  _emptySlotInputs: ->
    @$slotInputs.find('input').val ''

  _populateUiSlots: (index, checkbox) ->
    date = @._splitDateAndSlot(checkbox.val())[0]

    label = checkbox.closest('label')
    day = label.siblings('h4').text()
    time = label.find('strong').text()
    
    $slot = @$selectedSlots.eq(index)

    $slot.addClass 'is-active'
    $slot.find('.date').text day
    $slot.find('.time').text time
    # store reference to checkbox
    $slot.find('.js-remove-slot').data 'slot-option', checkbox

  _populateSlotInputs: (index, chosen) ->
    slot = @_splitDateAndSlot chosen
    @$slotInputs.eq(index).find('[name$="date]"]').val slot[0]
    @$slotInputs.eq(index).find('[name$="times]"]').val slot[1]

  _processSlots: ->
    _this = this

    @$slotOptions.filter(':checked').each (i) ->
      _this.highlightSlot $(this).closest('label')
      # _this._highlightDay $(this).closest '.js-slotpicker-options'
      _this._populateSlotInputs i, $(this).val()
      _this._populateUiSlots i, $(this)

  # _unHighlightDays: ->
  #   @$slotDays.removeClass @settings.selections

  # _highlightDay: (el) ->
  #   day = $ "[href=##{el.attr('id')}]"
  #   day.addClass @settings.selections

  _limitReached: ->
    @$slotOptions.filter(':checked').length >= @settings.optionlimit

  _disableCheckboxes: (disable) ->
    @$slotOptions.not(':checked').prop 'disabled', disable
    @$slotOptions.not(':checked').closest('label')[if disable then 'addClass' else 'removeClass'] 'is-disabled'

  _splitDateAndSlot: (str) ->
    bits = str.split '-'
    time = bits.splice(-2).join '-'
    [bits.join('-'),time]


# Add module to MOJ namespace
moj.Modules.slotPicker = init: ->
  $('.js-slotpicker').each ->
    $(this).data 'moj.slotpicker', new SlotPicker($(this), $(this).data())


zero_padding = (n) ->
  ('0' + n).slice -2

shortDate = (d) ->
  [
    d.getFullYear()
    d.getMonth()
    d.getDate()
  ].join('-')

bookableDates = []
for bookable_date of window.date_range
  bd = new Date(window.date_range[bookable_date])
  bookableDates.push shortDate(bd)

# Fullcalendar
$('#calendar').fullCalendar
  header:
    left: 'prev'
    center: 'title'
    right: 'next'

  dayClick: (date, allDay, jsEvent, view) ->
    $day = $( jsEvent.target ).closest( '.fc-day' )

    day = zero_padding date.getDate()
    month = zero_padding date.getMonth()+1
    year = date.getFullYear()
    $('.js-slotpicker-options').removeClass 'is-active'
    $("#date-#{year}-#{month}-#{day}").addClass 'is-active'

    $('.fc-day').removeClass('fc-state-highlight')
    $day.addClass('fc-state-highlight')

  dayRender: (date, cell) ->
    cellDate = shortDate date
    unless ~bookableDates.indexOf(cellDate)
      cell.addClass('fc-unavailable')

    if (!!~unavailable_days.indexOf(date.getDay()))
      cell.addClass('fc-unavailable')
