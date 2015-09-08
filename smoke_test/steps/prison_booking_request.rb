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
        "Visit request for #{prisoner_name} on #{first_slot_date}"
      end

      def prisoner_name
        prisoner = SmokeTest::TEST_DATA.fetch :prisoner_details
        "#{prisoner[:first_name]} #{prisoner[:last_name]}"
      end

      def first_slot_date
        state[:slot_data].first[:date]
      end

      def booking_processing_url
        Nokogiri::HTML(email.html_part.body.decoded).
          at('a:contains("Process the booking")')['href']
      end
    end
  end
end
