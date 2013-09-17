# jslint browser: true, evil: false, plusplus: true, white: true, indent: 2, nomen: true 

# global moj, $ 

# SlotPicker modules for MOJ
# Dependencies: moj, jQuery

"use strict"

# Define the class
SlotPicker = (el) ->
  @cacheEls el
  @bindEvents()

SlotPicker:: =
  defaults:
    optionLimit: 3
    selections: 'has-selections'

  cacheEls: (wrap) ->
    @$slots = $ '.js-slotpicker-slot [type=text]'
    @$dates = $ '.js-slotpicker-slot [type=date]'
    @$slotOptions = $ '.js-slotpicker-option'
    @$slotDays = $ '.js-slotpicker-day'

  bindEvents: ->
    # store a reference to obj before 'this' becomes jQuery obj
    _this = this
    
    @$slotOptions.on "click", (e) ->
      _this._emptySlots()
      _this._unHighlightDays()
      _this._populateSlots()
      _this._disableCheckboxes _this._limitReached()

  _emptySlots: ->
    @$slots.val ''

  _populateSlots: ->
    _this = this
    chosenSlots = []

    @$slotOptions.filter(':checked').each (i) ->
      chosenSlots.push $(this).val()

      _this._highlightDay $(this).closest '.js-slotpicker-options'

      while i < chosenSlots.length
        slot = _this._splitDateAndSlot chosenSlots[i]
        _this.$dates.eq(i).val slot[0]
        _this.$slots.eq(i).val slot[1]
        i++

  _unHighlightDays: ->
    @$slotDays.removeClass @defaults.selections

  _highlightDay: (el) ->
    day = $ "[href=##{el.attr('id')}]"
    day.addClass @defaults.selections

  _limitReached: ->
    @$slotOptions.filter(':checked').length >= @defaults.optionLimit

  _disableCheckboxes: (disable) ->
    @$slotOptions.not(':checked').prop 'disabled', disable

  _splitDateAndSlot: (str) ->
    bits = str.split '-'
    slot = bits.pop()
    [bits.join('-'),slot]


# Add module to MOJ namespace
moj.Modules.slotPicker = init: ->
  $('.js-slotpicker').each ->
    $(this).data 'moj.slotpicker', new SlotPicker($(this))
