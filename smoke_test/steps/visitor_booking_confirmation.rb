module SmokeTest
  module Steps
    class VisitorBookingConfirmation < BaseStep

      def validate!
        fail 'Could not find visitor booking confirmation email' if email.nil?
      end

      def complete_step
        visit cancel_booking_url
      end

      private

      def email
        @email ||=
          with_retries do
            mail_lookup.last_email_matching expected_email_subject
          end
      end

      def expected_email_subject
        "Visit confirmed: your visit for #{first_slot_date} has been confirmed"
      end

      def first_slot_date
        Date.parse(state[:slot_data].first[:date]).strftime('%-e %B %Y')
      end

      def cancel_booking_url
        Nokogiri::HTML(email.html_part.body.decoded).
          at('a:contains("you can cancel this visit")')['href']
      end
    end
  end
end

