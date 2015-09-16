module MailUtilities
  SmokeTestEmailCheck = Struct.new(:email_address) do
    def matches?
      smoke_test_email_regex.match(email_address)
    end

    private

    def smoke_test_email_regex
      %r{
        \A             # match from the start of the string
        #{local_part}
        \+             # google address alias see: https://support.google.com/mail/answer/12096
        [0-9a-z\-]{36} # RFC 4122 uuid extension
        @              # its an email!
        #{domain}
        \z             # match until the end of the string
      }x
    end

    def local_part
      Regexp.escape(Rails.configuration.smoke_test_email_local_part)
    end

    def domain
      Regexp.escape(Rails.configuration.smoke_test_email_domain)
    end
  end
end
