require 'poltergeist_helper'

RSpec.feature "deserialization" do
  include ActiveJobHelper
  include FeaturesHelper

  def name
    RandomString.random_string(30)
  end

  it 'should allow reasonably long names' do
    visit prisoner_details_path
    enter_prisoner_information first_name: name, last_name: name

    enter_visitor_information first_name: name, last_name: name
    select '5', from: 'visit_visitor__number_of_adults'

    enter_additional_visitor_information 1, :adult, first_name: name, last_name: name
    enter_additional_visitor_information 2, :adult, first_name: name, last_name: name
    enter_additional_visitor_information 3, :child, first_name: name, last_name: name
    enter_additional_visitor_information 4, :child, first_name: name, last_name: name
    enter_additional_visitor_information 5, :child, first_name: name, last_name: name

    click_button 'Continue'

    all('.BookingCalendar-date--bookable .BookingCalendar-dateLink').
      take(3).
      each do |date|
        date.trigger('click')
        first('.SlotPicker-slot').trigger('click')
      end

    click_button 'Continue'

    click_button 'Send request'

    urls = ActionMailer::Base.deliveries.flat_map { |d|
      d.text_part.body.decoded.lines.grep(/http/)
    }.uniq

    states = urls.map { |u| u[/state=(.+)/, 1] }.compact.uniq

    states.each do |s|
      puts s, '', s.length
    end
  end
end
