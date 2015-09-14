class EmailValidator < ActiveModel::Validator
  BAD_DOMAINS = File.readlines("data/bad_domains.txt").map(&:chomp)

  extend Forwardable
  def_delegators :SendgridApi, :bounced?, :spam_reported?

  def validate(record)
    key = error_key(record)
    if key
      msg = I18n.t(key, scope: 'email_validator.errors')
      record.errors.add :email, msg
    end
  end

  private

  def error_key(record)
    parsed = Mail::Address.new(record.email)
    return :domain_dot if domain_dot_error?(parsed.domain)
    return :bad_domain if bad_domain?(parsed.domain)
    return :malformed_address unless well_formed_address?(record, parsed)
    return :no_mx_record unless has_mx_records?(parsed.domain)
    return :spam_reported if spam_reported?(parsed.address)
    return :bounced if bounced?(parsed.address)
    return nil
  rescue Mail::Field::ParseError
    return :invalid_address
  end

  def domain_dot_error?(domain)
    domain.present? && (domain.end_with?('.') || domain.start_with?('.'))
  end

  def bad_domain?(domain)
    BAD_DOMAINS.include?(domain)
  end

  def well_formed_address?(record, parsed)
    parsed.local && parsed.domain &&
      parsed.address == record.email && parsed.local != record.email
  end

  def has_mx_records?(domain)
    Resolv::DNS.new.getresource(domain, Resolv::DNS::Resource::IN::MX)
  rescue Resolv::ResolvError
    false
  rescue Resolv::ResolvTimeout
    true
  end
end
