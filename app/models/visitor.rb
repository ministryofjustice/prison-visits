class Visitor
  include NonPersistedModel
  include Person

  USER_MIN_AGE = 18

  attribute :email, String
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

  private

  def validate_email
    validator = EmailValidator.new(email)
    errors.add :email, validator.message unless validator.valid?
  end
end
