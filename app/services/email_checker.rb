class EmailChecker
  BAD_DOMAINS = File.readlines("data/bad_domains.txt").map(&:chomp)

  extend Forwardable
  def_delegators :SendgridApi, :bounced?, :spam_reported?

  def initialize(original_address, override_sendgrid = false)
    @original_address = original_address
    @parsed = parse_address(original_address)
    @override_sendgrid = override_sendgrid
  end

  def error
    unless @error_checked
      @error = compute_error
      @error_checked = true
    end
    @error
  end

  def message
    I18n.t(error, scope: 'email_checker.errors')
  end

  def valid?
    error.nil?
  end

  def overrideable?
    [:spam_reported, :bounced].include?(error)
  end

  def reset_bounce?
    return false unless parsed
    override_sendgrid? && bounced?(parsed.address)
  end

  def reset_spam_report?
    return false unless parsed
    override_sendgrid? && spam_reported?(parsed.address)
  end

  private

  attr_reader :original_address, :parsed

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def compute_error
    return :unparseable unless parsed
    return :domain_dot if domain_dot_error?
    return :bad_domain if bad_domain?
    return :malformed unless well_formed_address?
    return :no_mx_record unless has_mx_records?
    unless override_sendgrid?
      return :spam_reported if spam_reported?(parsed.address)
      return :bounced if bounced?(parsed.address)
    end
    nil
  end

  def override_sendgrid?
    @override_sendgrid
  end

  def domain
    parsed.domain
  end

  def parse_address(addr)
    Mail::Address.new(addr)
  rescue Mail::Field::ParseError
    nil
  end

  def domain_dot_error?
    domain && domain.start_with?('.')
  end

  def bad_domain?
    BAD_DOMAINS.include?(domain)
  end

  def well_formed_address?
    parsed.local && parsed.domain &&
      parsed.address == original_address && parsed.local != original_address
  end

  def has_mx_records?
    Resolv::DNS.new.getresource(domain, Resolv::DNS::Resource::IN::MX)
  rescue Resolv::ResolvError
    false
  rescue Resolv::ResolvTimeout
    true
  end
end
