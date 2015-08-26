module SmokeTest
  module Steps
    class PrisonerPage < BaseStep

      PAGE_PATH = '/prisoner'

      def assert_validity!
        if page.current_path != PAGE_PATH
          fail "expected #{PAGE_PATH}, got #{page.current_path}"
        end
      end

      def complete_step
        fill_in 'Prisoner first name', with: prisoner[:first_name]
        fill_in 'Prisoner last name', with: prisoner[:last_name]
        fill_in 'Day', with: prisoner[:birth_day]
        fill_in 'Month', with: prisoner[:birth_month]
        fill_in 'Year', with: prisoner[:birth_year]
        fill_in 'Prisoner number', with: prisoner[:prison_number]
        fill_in_prison_name_with prisoner[:prison_name]
        click_button 'Continue'
      end

      private

      def prisoner
        SmokeTest::TEST_DATA.fetch :prisoner_details
      end

      def fill_in_prison_name_with(prison_name)
        find('.ui-autocomplete-input').set(prison_name)
      end
    end
  end
end
