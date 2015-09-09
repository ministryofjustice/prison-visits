module SmokeTest
  module Steps
    class PrisonBookingCancelled < BaseStep

      def validate!
        fail 'Could not find prison booking cancelled email' unless email
      end

      def complete_step
        # nothing for us to do with this email
      end

      private

      def email
        @email ||=
          with_retries do
            MailBox.find_email state.unique_email_address, expected_email_subject
          end
      end

      def expected_email_subject
        "CANCELLED: #{state.prisoner.full_name} on #{state.first_slot_date_prison_format}"
      end
    end
  end
end

