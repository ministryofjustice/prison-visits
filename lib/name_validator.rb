class NameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && (value.include?('<') || value.include?('>'))
      record.errors.add(attribute, "is not a valid name")
    end
  end
end
