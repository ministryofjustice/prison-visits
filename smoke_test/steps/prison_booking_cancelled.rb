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
        "CANCELLED: #{state.prisoner.full_name} on #{state.first_slot_date_prison_format}"
      end
    end
  end
end

