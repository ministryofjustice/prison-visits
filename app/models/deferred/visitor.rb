class Deferred::Visitor < Visitor
  def validate_user_or_additional
    super
    if index.zero?
      errors.add(:phone, 'must be given and include area code') unless phone.present? && phone.size > 9
    else
      errors.add(:phone, 'must not be given') if phone.present?
    end
  end
end
