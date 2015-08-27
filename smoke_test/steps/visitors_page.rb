module SmokeTest
  module Steps
    class VisitorsPage < BaseStep

      PAGE_PATH = '/deferred/visitors'

      def validate!
        if page.current_path != PAGE_PATH
          fail "expected #{PAGE_PATH}, got #{page.current_path}"
        end
      end

      def complete_step
        fill_in 'Your first name', with: visitor[:first_name]
        fill_in 'Your last name', with: visitor[:last_name]
        fill_in 'Day', with: visitor[:birth_day]
        fill_in 'Month', with: visitor[:birth_month]
        fill_in 'Year', with: visitor[:birth_year]
        fill_in 'Email address', with: visitor[:email_address]
        fill_in 'Phone number', with: visitor[:phone_number]
        click_button 'Continue'
      end

      private

      def visitor
        SmokeTest::TEST_DATA.fetch :visitor_details
      end
    end
  end
end
