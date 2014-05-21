require 'browserstack_helper'

feature "visitor selects a date" do
  include_examples "feature helper"

  before :each do
    visit '/'
    enter_prisoner_information
    enter_visitor_information
    click_button 'Continue'
  end

  context "that is unbookable" do
    it "and displays a message saying booking is not possible" do
      yesterday = Time.now - 1.day

      # If the week starts on Monday, don't run this test - "yesterday" will be beyond the first
      # row of the calendar.
      if ![0, 7].include?(yesterday.wday)
        find(:css, yesterday.strftime("a.BookingCalendar-dayLink[data-date='%Y-%m-%d']")).click
        page.should have_content("It is not possible to book a visit in the past.")
      end

      tomorrow = Time.now + 1.day
      find(:css, tomorrow.strftime("a.BookingCalendar-dayLink[data-date='%Y-%m-%d']")).click
      page.should have_content('You can only book a visit 3 days in advance.')

      a_month_from_now = Time.now + 29.days
      find(:css, a_month_from_now.strftime("a.BookingCalendar-dayLink[data-date='%Y-%m-%d']")).click
      page.should have_content('You can only book a visit in the next 28 days.')
    end
  end

  context "that is bookable" do
    it "displays booking slots" do
      _when = Time.now + 3.days
      begin
        find(:css, _when.strftime("a.BookingCalendar-dayLink[data-date='%Y-%m-%d']")).click
        # Some dates are not bookable, ignore those.
        find(:css, _when.strftime("#date-%Y-%m-%d.is-active input[value='%Y-%m-%d-1400-1600']"))
      rescue Capybara::ElementNotFound
        _when += 1.day
        retry unless _when > Time.now + 30.days
      end

      within(:css, _when.strftime("#date-%Y-%m-%d.is-active")) do
        page.should have_content(_when.strftime("%A %e %B"))
        check('2:00pm 2 hrs')
      end

      click_button 'Continue'
      page.should have_content('Check your request')

      click_button 'Send request'
      page.should have_content('Your visit request has been sent')
    end
  end
end
