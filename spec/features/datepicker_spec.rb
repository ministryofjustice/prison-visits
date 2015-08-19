require 'browserstack_helper'

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
    allow_any_instance_of(EmailValidator).to receive(:validate_dns_records)
    allow_any_instance_of(EmailValidator).to receive(:validate_spam_reporter)
    allow_any_instance_of(EmailValidator).to receive(:validate_bounced)
  end

  context "deferred flow" do
    before :each do
      visit '/prisoner-details'
      enter_prisoner_information(:deferred)
      enter_visitor_information(:deferred)
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
        expect(page).to have_content(_when.strftime("%A %e %B"))
      end

      # For some reason, check() can't find the checkbox.
      evaluate_script(_when.strftime("$('#slot-%Y-%m-%d-1330-1500').click()"))
      evaluate_script(_when.strftime("$('#slot-%Y-%m-%d-1445-1545').click()"))

      click_button 'Continue'
      expect(page).to have_content('Check your request')
      expect(page).to have_selector('.AgeLabel-label', :text => 'Over 18')

      click_button 'Send request'
      expect(page).to have_content('Your request is being processed')
    end
  end

  context "instant flow" do
    before :each do
      visit '/prisoner-details'
      enter_prisoner_information(:instant)
      enter_visitor_information(:instant)
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

    scenario 'Choosing a date more than 28 days from now' do
      all(:css, "a.BookingCalendar-dateLink").last.click
      expect(page).to have_content('You can only book a visit in the next 28 days')
    end

    scenario 'Booking a valid slot' do
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
        expect(page).to have_content(_when.strftime("%A %e %B"))
      end

      # For some reason, check() can't find the checkbox.
      evaluate_script(_when.strftime("$('#slot-%Y-%m-%d-1345-1545').click()"))
      evaluate_script(_when.strftime("$('#slot-%Y-%m-%d-1345-1645').click()"))

      click_button 'Continue'
      expect(page).to have_content('Check your request')
      expect(page).to have_selector('.AgeLabel-label', :text => 'Over 18')

      click_button 'Send request'
      expect(page).to have_content('Your request is being processed')
    end
  end
end
