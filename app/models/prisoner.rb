class Prisoner
  include NonPersistedModel
  include Person

  attribute :number, String
  attribute :prison_name, String

  validates :number, format: {
    with: /\A[a-z]\d{4}[a-z]{2}\z/i
  }

  validates :prison_name, inclusion: {
    in: Prison.names,
    message: "must be chosen" }
  validate :prison_in_service
  validates :prison_name, inclusion: {
    in: Rails.configuration.prison_data.keys

  validate :prison_in_service

  def prison_in_service
    unless prison && prison.enabled?
    if prison_name.present? &&
      !Rails.configuration.prison_data[prison_name]['enabled']
      errors.add(:prison_name, 'is not available')
      errors.add(:prison_name_reason, true)
    end
  end
end
