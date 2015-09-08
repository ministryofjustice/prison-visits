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
  validate :validate_email, if: :primary?

  def validate_email
    EmailValidator.new.validate(self)
  end

  def primary?
    index == 0
  end

  def additional?
    index > 0
  end
end
