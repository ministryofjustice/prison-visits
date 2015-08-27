module SmokeTest
  module Steps
    class VisitorBookingReceipt < BaseStep

      def assert_validity!
        fail 'Could not find visitor booking receipt email' if email.nil?
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
        "Not booked yet: we've received your visit request for#{first_slot_date}"
      end

      def first_slot_date
        Date.parse(state[:slot_data].first[:date]).strftime('%e %B %Y')
      end
    end
  end
end
