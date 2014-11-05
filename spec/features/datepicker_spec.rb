require 'browserstack_helper'

feature "visitor selects a date" do
  include_examples "feature helper"

  before :each do
    VisitController.any_instance.stub(:metrics_logger).and_return(MockMetricsLogger.new)
    EmailValidator.any_instance.stub(:has_mx_records).and_return(true)
    visit '/prisoner-details'
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
        find(:css, yesterday.strftime("a.BookingCalendar-dateLink[data-date='%Y-%m-%d']")).click
        page.should have_content("It is not possible to book a visit in the past.")
      end

      tomorrow = Time.now + 1.day
      find(:css, tomorrow.strftime("a.BookingCalendar-dateLink[data-date='%Y-%m-%d']")).click
      page.should have_content('You can only book a visit 3 working days in advance.')

      a_month_from_now = Time.now + 29.days
      find(:css, a_month_from_now.strftime("a.BookingCalendar-dateLink[data-date='%Y-%m-%d']")).click
      page.should have_content('You can only book a visit in the next')
    end
  end

  context "that is bookable" do
    it "displays booking slots" do
      _when = Time.now + 3.days
      begin
        find(:css, _when.strftime("a.BookingCalendar-dateLink[data-date='%Y-%m-%d']")).click
        # Some dates are not bookable, ignore those.
        find(:css, _when.strftime("#date-%Y-%m-%d.is-active"))
      rescue Capybara::ElementNotFound => e
        _when += 1.day
        retry unless _when > Time.now + 30.days
      end

      within(:css, _when.strftime("#date-%Y-%m-%d.is-active")) do
        page.should have_content(_when.strftime("%A %e %B"))
      end
      
      # For some reason, check() can't find the checkbox.
      evaluate_script(_when.strftime("$('#slot-%Y-%m-%d-1350-1450').click()"))

      click_button 'Continue'
      page.should have_content('Check your request')

      click_button 'Send request'
      page.should have_content('Your request is being processed')
    end
  end
end
