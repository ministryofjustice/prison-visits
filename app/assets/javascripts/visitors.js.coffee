additionalVisitors = $('#visitor-1, #visitor-2, #visitor-3, #visitor-4, #visitor-5')
addVisitor = $('#add-visitor')
visitors = $('.visitor')

summarise = (visitor) ->
  visitor.addClass 'compact'
  visitor.removeClass 'js-editing'
  
  name = visitor.find('[name$="[full_name]"]').val()
  dob = visitor.find('[name$="[date_of_birth]"]').val()

  visitor.find('.summary .name').text name
  visitor.find('.summary .dob').text dob

  visitor.find('.js-save-visitor').addClass('button-secondary').removeClass('button-primary').text('Save this visitor')

edit = (visitor) ->
  visitor.show().removeClass 'compact'
  visitor.addClass 'js-editing'
  visitor.find('input').first().focus()

highlightContinue = (highlight) ->
  $('#continue')[if highlight then 'addClass' else 'removeClass'] 'button-primary'

toggleAdd = ->
  slotsLeft = visitors.length < 6
  noEdits = additionalVisitors.filter('.js-editing').length is 0
  addVisitor[if noEdits and slotsLeft then 'show' else 'hide']()

# 'Add' a visitor
addVisitor.on 'click', (e) ->
  e.preventDefault()

  summarise $('#visitor-0')
  
  edit $('.visitor').first()
  
  highlightContinue false
  toggleAdd()

# 'Save' a visitor
$('.js-save-visitor').click (e) ->
  e.preventDefault()
  
  summarise $(this).closest('.visitor')
  
  toggleAdd()
  highlightContinue true

# Edit a visitor
$('.js-edit-visitor').on 'click', (e) ->
  e.preventDefault()
  edit $(this).closest('.visitor')

  toggleAdd()

# 'Cancel' a visitor
additionalVisitors.on 'click', '.js-delete-visitor', (e) ->
  e.preventDefault()
  
  visitor = $(this).closest('.visitor')
  
  visitor.find('input').val ''
  visitor.hide().removeClass 'js-editing'
  
  toggleAdd()
  highlightContinue true
