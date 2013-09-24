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
    @$slots = $ '.js-slotpicker-slot [type=text]'
    @$dates = $ '.js-slotpicker-slot [type=date]'
    @$slotOptions = $ '.js-slotpicker-option'
    @$slotDays = $ '.js-slotpicker-day'
    @$selectedSlots = $ '.selected-slots li'
    @removeSlots = '.js-remove-slot'

  bindEvents: ->
    # store a reference to obj before 'this' becomes jQuery obj
    _this = this
    
    @$slotOptions.on 'click', (e) ->
      _this._emptySlots()
      _this._emptySlotInputs()
      _this._unHighlightDays()
      _this._processSlots()
      _this._disableCheckboxes _this._limitReached()

    @$wrapper.on 'click', @removeSlots, (e) ->
      e.preventDefault()
      console.log $(this).data('slot-option')
      $( $(this).data('slot-option') ).click()

  checkSlots: (slots) ->
    for slot in slots
      $("[value='#{slot.date}-#{slot.slot}']").click()

  _emptySlots: ->
    slots = @$selectedSlots
    slots.removeClass 'is-active'
    slots.find('a').removeData()
    slots.find('.date, .time').text ''

  _emptySlotInputs: ->
    @$slots.val ''

  _populateSelectedSlots: (index, checkbox) ->
    id = checkbox.closest('.js-slotpicker-options').attr 'id'
    day = $("[href=##{id}]").text()
    time = checkbox.closest('label').text()
    $slot = @$selectedSlots.eq(index)

    $slot.addClass 'is-active'
    $slot.find('.date').text day
    $slot.find('.time').text time
    # store reference to checkbox
    $slot.find('.js-remove-slot').data 'slot-option', checkbox

  _populateSlotInputs: (index, chosen) ->
    slot = @_splitDateAndSlot chosen
    @$dates.eq(index).val slot[0]
    @$slots.eq(index).val slot[1]

  _processSlots: ->
    _this = this

    @$slotOptions.filter(':checked').each (i) ->
      _this._highlightDay $(this).closest '.js-slotpicker-options'
      _this._populateSlotInputs i, $(this).val()
      _this._populateSelectedSlots i, $(this)

  _unHighlightDays: ->
    @$slotDays.removeClass @settings.selections

  _highlightDay: (el) ->
    day = $ "[href=##{el.attr('id')}]"
    day.addClass @settings.selections

  _limitReached: ->
    @$slotOptions.filter(':checked').length >= @settings.optionlimit

  _disableCheckboxes: (disable) ->
    @$slotOptions.not(':checked').prop 'disabled', disable

  _splitDateAndSlot: (str) ->
    bits = str.split '-'
    slot = bits.pop()
    [bits.join('-'),slot]


# Add module to MOJ namespace
moj.Modules.slotPicker = init: ->
  $('.js-slotpicker').each ->
    $(this).data 'moj.slotpicker', new SlotPicker($(this), $(this).data())


$('.month-selector li a').click (e) ->
  e.preventDefault()
  
  $('.month-selector li').removeClass 'is-active is-earlier is-later'
  
  $(this).closest('.month-selector li').addClass 'is-active'
  
  $('.month-selector li').each ->
    if $(this).nextAll('li').filter('.is-active').length
      $(this).addClass('is-earlier')
    if $(this).prevAll('li').filter('.is-active').length
      $(this).addClass('is-later')
