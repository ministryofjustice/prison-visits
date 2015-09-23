module SmokeTest
  module Steps
    class VisitorBookingConfirmation < BaseStep
      def validate!
        fail 'Could not find visitor booking confirmation email' unless email
      end

      def complete_step
        visit cancel_booking_url
      end

      private

      def email
        @email ||= with_retries do
          MailBox.find_email state.unique_email_address, expected_email_subject
        end
      end

      def expected_email_subject
        "Visit confirmed: your visit for %s has been confirmed" % [
          state.first_slot_date_visitor_format
        ]
      end

      def cancel_booking_url
        Nokogiri::HTML(email.html_part.body.decoded).
          at('a:contains("you can cancel this visit")')['href']
      end
    end
  end
end
