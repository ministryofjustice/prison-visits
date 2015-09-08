class Prisoner
  include NonPersistedModel
  include Person

  attribute :number, String
  attribute :prison_name, String

  validates_format_of :number, with: /\A[a-z]\d{4}[a-z]{2}\z/i, message: "must be a valid prisoner number" # eg a1234aa
  validates_inclusion_of :prison_name, in: Rails.configuration.prison_data.keys, message: "must be chosen"
  validate :prison_in_service

  def prison_in_service
    if !self.prison_name.blank? && !Rails.configuration.prison_data[self.prison_name]['enabled']
      errors.add(:prison_name, 'is not available')
      errors.add(:prison_name_reason, true)
    end
  end
end
