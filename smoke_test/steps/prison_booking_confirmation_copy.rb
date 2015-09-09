module SmokeTest
  module Steps
    class PrisonBookingConfirmationCopy < BaseStep

      def validate!
        fail 'Could not find prison booking confirmation copy email' unless email
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
        "COPY of booking confirmation for #{state.prisoner.full_name}"
      end
    end
  end
end
