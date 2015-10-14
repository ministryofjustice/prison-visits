class Visitor
  include NonPersistedModel
  include Person

  USER_MIN_AGE = 18

  attribute :email, String
  attribute :override_email_checks, Boolean
  attribute :email_override, String
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

  def override_email_checks?
    @override_email_checks
  end

  private

  def validate_email
    checker = EmailChecker.new(email, override_email_checks)
    unless checker.valid?
      errors.add :email, checker.message
      @email_overrideable = checker.overrideable?
      @email_override = checker.error
    end
  end
end
