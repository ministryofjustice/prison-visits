module SmokeTest
  module Steps
    class ProcessVisitRequestPage < BaseStep

      PAGE_PATH = '/deferred/confirmation/new'

      def assert_validity!
        if page.current_path != PAGE_PATH
          fail "expected #{PAGE_PATH}, got #{page.current_path}"
        end
      end

      def complete_step
        save_screenshot 'test.png'
        choose "First choice"
        fill_in "Reference number", with: process_data[:vo_digits]
        click_button 'Send email'
      end

      private

      def process_data
        SmokeTest::TEST_DATA.fetch :process_data
      end
    end
  end
end
