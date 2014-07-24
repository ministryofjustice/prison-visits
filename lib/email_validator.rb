class EmailValidator < ActiveModel::Validator
  def validate(record)
    parsed = Mail::Address.new(record.email)
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
end
