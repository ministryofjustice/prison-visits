class EmailValidator < ActiveModel::Validator
  def validate(record)
    parsed = Mail::Address.new(record.email)
    maybe_set_error(record, "is not a valid address because it ends with a dot or starts with a dot") do
      parsed.domain.present? && (parsed.domain.end_with?('.') || parsed.domain.start_with?('.'))
    end
    unless parsed.local &&
        parsed.domain &&
        parsed.address == record.email &&
        parsed.local != record.email &&
        has_mx_records(parsed.domain)
      set_error(record)
    end
  rescue Mail::Field::ParseError
    set_error(record)
  end

  def has_mx_records(domain)
    Resolv::DNS.open do |dns|
      return dns.getresources(domain, Resolv::DNS::Resource::IN::MX).any?
    end
  rescue Resolv::ResolvError, Resolv::ResolvTimeout
    true
  end

  def set_error(record)
    record.errors.add(:email, "is not a valid address")
  end

  def maybe_set_error(record, message)
    record.errors.add(:email, message) if yield
  end
end
