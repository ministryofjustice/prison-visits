# Fill in forms when we're using Rack::Test rather than Poltergeist (essential
# when we want to freeze time in the feature).
#
module RackTestFeaturesHelper
  def status
    page.driver.browser.last_response.status
  end

  def complete_prisoner_details(prison_name)
    fill_in 'Prisoner first name', with: 'Arthur'
    fill_in 'Prisoner last name', with: 'Raffles'
    fill_in 'Day', with: '1'
    fill_in 'Month', with: '1'
    fill_in 'Year', with: '1980'
    fill_in 'Prisoner number', with: 'a1234bc'
    select prison_name, from: 'Name of the prison'
  end

  def complete_visitor_details
    fill_in 'Your first name', with: 'Harry'
    fill_in 'Your last name', with: 'Manders'
    fill_in 'Day', with: '1'
    fill_in 'Month', with: '1'
    fill_in 'Year', with: '1980'
    fill_in 'Email address', with: 'user@digital.justice.gov.uk'
    fill_in 'Phone number', with: '0115 496 0123'
  end

  def complete_visit_details
    slot = first('.SlotPicker-input option[value!=""]').text
    select slot, from: 'Option 1'
  end
end
