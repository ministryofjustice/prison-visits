require 'poltergeist_helper'

RSpec.feature "visitor selects a date" do
  include ActiveJobHelper

  include_examples "feature helper"

  before :all do
    Timecop.travel(Time.now.next_week(:tuesday).at_noon)
  end

  after :all do
    Timecop.return
  end

  before :each do
    allow_any_instance_of(VisitController).to receive(:metrics_logger).and_return(MockMetricsLogger.new)
    visit edit_prisoner_details_path
    enter_prisoner_information
    enter_visitor_information
    click_button 'Continue'
  end

  scenario 'Choosing a date in the past' do
    yesterday = Time.now - 1.day
    find(:css, yesterday.strftime("a.BookingCalendar-dateLink[data-date='%Y-%m-%d']")).click
    expect(page).to have_content("It is not possible to book a visit in the past.")
  end

  scenario 'Choosing a date more than 3 working days from now' do
    tomorrow = Time.now + 1.day
    find(:css, tomorrow.strftime("a.BookingCalendar-dateLink[data-date='%Y-%m-%d']")).click
    expect(page).to have_content('You can only book a visit 3 working days in advance.')
  end

  scenario 'Choosing a date more than 14 days from now' do
    all(:css, "a.BookingCalendar-dateLink").last.click
    expect(page).to have_content('You can only book a visit in the next 14 days')
  end

  scenario 'Booking a valid slot' do
    three_days_from_now = Time.now + 3.days
    begin
      find(:css, three_days_from_now.strftime("a.BookingCalendar-dateLink[data-date='%Y-%m-%d']")).click
      # Some dates are not bookable, ignore those.
      find(:css, three_days_from_now.strftime("#date-%Y-%m-%d.is-active"))
    rescue Capybara::ElementNotFound
      three_days_from_now += 1.day
      retry unless three_days_from_now > Time.now + 30.days
    end

    within(:css, three_days_from_now.strftime("#date-%Y-%m-%d.is-active")) do
      expect(page).to have_content(three_days_from_now.strftime("%A %e %B"))
    end

    # For some reason, check() can't find the checkbox.
    evaluate_script(three_days_from_now.strftime("$('#slot-%Y-%m-%d-1330-1500').click()"))
    evaluate_script(three_days_from_now.strftime("$('#slot-%Y-%m-%d-1445-1545').click()"))

    click_button 'Continue'
    expect(page).to have_content('Check your request')
    expect(page).to have_selector('.AgeLabel-label', :text => 'Over 18')

    click_button 'Send request'
    expect(page).to have_content('Your request is being processed')
  end
end
