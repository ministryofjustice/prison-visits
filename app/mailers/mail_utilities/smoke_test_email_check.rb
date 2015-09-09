module MailUtilities
  class SmokeTestEmailCheck < Struct.new(:email_address)
    SMOKE_TEST_EMAIL_REGEX = %r{
    \A              # match from the start of the string
    #{Regexp.escape ENV.fetch('SMOKE_TEST_EMAIL_LOCAL_PART')}
    \+              # enable google address aliases see: https://support.google.com/mail/answer/12096
    [0-9a-z\-]{36}  # RFC 4122 uuid extension
    @               # its an email!
    #{Regexp.escape ENV.fetch('SMOKE_TEST_EMAIL_DOMAIN')}
    \z              # match until the end of the string
    }x

    def matches?
      SMOKE_TEST_EMAIL_REGEX.match(email_address)
    end
  end
end

