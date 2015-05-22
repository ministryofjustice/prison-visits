require 'browserstack_helper'

feature "visitor selects a date" do
  include_examples "feature helper"

  [:deferred, :instant].each do |flow|
    context "#{flow} flow" do

      before :each do
        allow_any_instance_of(VisitController).to receive(:metrics_logger).and_return(MockMetricsLogger.new)
        allow_any_instance_of(EmailValidator).to receive(:validate_dns_records)
        allow_any_instance_of(EmailValidator).to receive(:validate_spam_reporter)
        allow_any_instance_of(EmailValidator).to receive(:validate_bounced)
        visit '/prisoner-details'
        enter_prisoner_information(flow)
        enter_visitor_information(flow)
        click_button 'Continue'
      end

      context "that is unbookable" do
        it "and displays a message saying booking is not possible" do
          yesterday = Time.now - 1.day

          # If the week starts on Monday, don't run this test - "yesterday" will be beyond the first
          # row of the calendar.
          if ![0, 7].include?(yesterday.wday)
            find(:css, yesterday.strftime("a.BookingCalendar-dateLink[data-date='%Y-%m-%d']")).click
            expect(page).to have_content("It is not possible to book a visit in the past.")
          end

          tomorrow = Time.now + 1.day
          find(:css, tomorrow.strftime("a.BookingCalendar-dateLink[data-date='%Y-%m-%d']")).click
          expect(page).to have_content('You can only book a visit 3 working days in advance.')

          a_month_from_now = Time.now + 29.days
          find(:css, a_month_from_now.strftime("a.BookingCalendar-dateLink[data-date='%Y-%m-%d']")).click
          expect(page).to have_content('You can only book a visit in the next')
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
            expect(page).to have_content(_when.strftime("%A %e %B"))
          end
          
          # For some reason, check() can't find the checkbox.
          if flow == :deferred
            evaluate_script(_when.strftime("$('#slot-%Y-%m-%d-1330-1500').click()"))
            evaluate_script(_when.strftime("$('#slot-%Y-%m-%d-1445-1545').click()"))
          else
            evaluate_script(_when.strftime("$('#slot-%Y-%m-%d-1345-1545').click()"))
            evaluate_script(_when.strftime("$('#slot-%Y-%m-%d-1345-1645').click()"))
          end

          click_button 'Continue'
          expect(page).to have_content('Check your request')
          expect(page).to have_tag('.AgeLabel-label', :text => 'Over 18')

          click_button 'Send request'
          expect(page).to have_content('Your request is being processed')
        end
      end
    end
  end
end
