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

SlotPicker:: =
  defaults:
    optionlimit: 3
    selections: 'has-selections'

  cacheEls: (wrap) ->
    @$slots = $ '.js-slotpicker-slot [type=text]'
    @$dates = $ '.js-slotpicker-slot [type=date]'
    @$slotOptions = $ '.js-slotpicker-option'
    @$slotDays = $ '.js-slotpicker-day'
    @$selectedSlots = $ '.selected-slots li'

  bindEvents: ->
    # store a reference to obj before 'this' becomes jQuery obj
    _this = this
    
    @$slotOptions.on "click", (e) ->
      _this._emptySlots()
      _this._unHighlightDays()
      _this._processSlots()
      _this._disableCheckboxes _this._limitReached()

  _emptySlots: ->
    @$slots.val ''

  _populateSelectedSlots: (index, el) ->
    @$selectedSlots.eq(index).find('.date').text el.val()

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
