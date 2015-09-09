class SmokeTestEmailCheck < Struct.new(:visit_session)
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
    SMOKE_TEST_EMAIL_REGEX.match(visitor_email_address)
  end

  private

  def visitor_email_address
    visit_session.visitors.first.email
  end
end
