class Prisoner
  include NonPersistedModel
  include Person

  attribute :number, String
  attribute :prison_name, String

  validates :number, format: {
    with: /\A[a-z]\d{4}[a-z]{2}\z/i
  }

  validates :prison_name, inclusion: { in: Prison.names }

  validate :prison_in_service

  delegate :email, :canned_responses, :nomis_id, to: :prison, prefix: :prison

  def prison
    Prison.find(prison_name)
  end

  private

  def prison_in_service
    unless prison && prison.enabled?
      errors.add(:prison_name, 'is not available')
      errors.add(:prison_name_reason, true)
    end
  end
end
