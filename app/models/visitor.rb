class Visitor
  include NonPersistedModel
  include Person

  USER_MIN_AGE = 18

  attribute :email, String
  attribute :override_email_checks, Boolean
  attribute :index, Integer
  attribute :number_of_adults, Integer
  attribute :number_of_children, Integer
  attribute :phone, String

  validates :email, absence: true, if: :additional?
  validates :email, presence: true, if: :primary?
  validate :validate_email, if: :primary?
  validates :phone, absence: true, if: :additional?
  validates :phone, presence: true, length: { minimum: 9 }, if: :primary?

  def primary?
    index == 0
  end

  def additional?
    index > 0
  end

  def email_overrideable?
    @email_overrideable
  end

  private

  def validate_email
    validator = EmailValidator.new(email, override_email_checks)
    unless validator.valid?
      errors.add :email, validator.message
      @email_overrideable = validator.overrideable?
    end
  end
end
