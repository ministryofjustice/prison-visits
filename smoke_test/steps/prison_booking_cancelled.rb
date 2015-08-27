module SmokeTest
  module Steps
    class PrisonBookingCancelled < BaseStep

      def validate!
        fail 'Could not find prison booking cancelled email' if email.nil?
      end

      def complete_step
        # nothing for us to do with this email
      end

      private

      def email
        @email ||=
          with_retries do
            mail_lookup.last_email_matching expected_email_subject
          end
      end

      def expected_email_subject
        "CANCELLED: #{prisoner_name} on #{first_slot_date}"
      end

      def prisoner_name
        prisoner = SmokeTest::TEST_DATA.fetch :prisoner_details
        "#{prisoner[:first_name]} #{prisoner[:last_name]}"
      end

      def first_slot_date
        state[:slot_data].first[:date]
      end
    end
  end
end

