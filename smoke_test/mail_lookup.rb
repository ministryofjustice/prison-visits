require 'mail'
require 'net/imap'

module SmokeTest
  class MailLookup < Struct.new(:since_date)

    SMOKE_TEST_EMAIL_ADDRESS = ENV.fetch 'SMOKE_TEST_EMAIL_ADDRESS'
    SMOKE_TEST_EMAIL_PASSWORD = ENV.fetch 'SMOKE_TEST_EMAIL_PASSWORD'

    def last_email_matching(expected_subject)
      client.login SMOKE_TEST_EMAIL_ADDRESS, SMOKE_TEST_EMAIL_PASSWORD
      client.examine 'INBOX'
      mail_ids = client.search(['SINCE', Net::IMAP.format_date(since_date)])

      client.fetch(mail_ids, 'RFC822').
        map(&method(:parse_email)).
        select(&method(:created_during_this_smoke_test?)).
        reverse.
        find { |parsed_email| parsed_email.subject == expected_subject }
    ensure
      client.logout
      client.disconnect
    end

    private

    def parse_email(msg)
      Mail.read_from_string(msg.attr['RFC822'])
    end

    def created_during_this_smoke_test?(email)
      # IMAP search using SINCE does not take
      # into account hours or minutes
      email.date.utc > since_date
    end

    def client
      @client ||= Net::IMAP.new('imap.gmail.com', port: 993, ssl: true)
    end
  end
end
