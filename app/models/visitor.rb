class Visitor
  include NonPersistedModel

  USER_MIN_AGE = 18
  USER_MAX_AGE = 120

  attribute :first_name, String
  attribute :last_name, String
  attribute :email, String
  attribute :index, Integer
  attribute :number_of_adults, Integer
  attribute :number_of_children, Integer
  attribute :date_of_birth, Date
  attribute :phone, String

  def full_name(glue=' ')
    [first_name, last_name].join(glue)
  end

  def last_initial
    @last_name.chars.first.upcase
  end

  validates :first_name, presence: true, name: true
  validates :last_name, presence: true, name: true
  validates_inclusion_of :date_of_birth,
    in: ->(_) { USER_MAX_AGE.years.ago.beginning_of_year.to_date..Date.today },
    message: 'must be a valid date'
  validate :validate_user_or_additional

  def validate_user_or_additional
    if index.zero?
      EmailValidator.new.validate(self)
    else
      errors.add(:email, 'must not be given') if email.present?
    end
  end

  def age
    if date_of_birth
      (Date.today - date_of_birth.to_date).to_i / 365
    end
  end
end
