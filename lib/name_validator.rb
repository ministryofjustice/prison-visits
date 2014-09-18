class NameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value

    if value.bytes.length > 30 || value.include?('<') || value.include?('>')
      record.errors.add(attribute, "is not a valid name")
    end
  end
end
