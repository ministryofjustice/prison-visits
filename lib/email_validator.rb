class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    parsed = Mail::Address.new(value)
    record.errors.add(attribute, "is not a valid address") unless parsed.address == value && parsed.local != value
  rescue Mail::Field::ParseError
    record.errors.add(attribute, "is not a valid address")
  end
end

