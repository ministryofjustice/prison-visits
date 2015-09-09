module SmokeTest
  module Steps
    class PrisonBookingRequest < BaseStep

      def validate!
        fail 'Could not find prison booking request email' if email.nil?
      end

      def complete_step
        visit booking_processing_url
      end

      private

      def email
        @email ||=
          with_retries { mail_lookup.last_email_matching expected_email_subject }
      end

      def expected_email_subject
        "Visit request for #{state.prisoner.full_name} on #{state.first_slot_date_prison_format}"
      end

      def booking_processing_url
        Nokogiri::HTML(email.html_part.body.decoded).
          at('a:contains("Process the booking")')['href']
      end
    end
  end
end
