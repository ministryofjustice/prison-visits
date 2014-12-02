class Visitor
  include ActiveModel::Model

  USER_MIN_AGE = 18

  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :email
  attr_accessor :index
  attr_accessor :number_of_adults
  attr_accessor :number_of_children
  attr_accessor :date_of_birth
  attr_accessor :phone

  def full_name(glue=' ')
    [first_name, last_name].join(glue)
  end

  def last_initial
    @last_name.chars.first.upcase
  end

  validates :first_name, presence: true, name: true
  validates :last_name, presence: true, name: true
  validates_inclusion_of :date_of_birth, in: ->(_) { 100.years.ago.beginning_of_year.to_date..Date.today }, message: 'must be a valid date'
  validate :validate_user_or_additional

  def validate_user_or_additional
    if index.zero?
      EmailValidator.new.validate(self)
      errors.add(:base, 'You must be over 18 years old to book a visit') unless date_of_birth.present? && date_of_birth < 18.years.ago
    else
      errors.add(:email, 'must not be given') if email.present?
    end
  end

  def age
    if date_of_birth
      (Date.today - date_of_birth.to_date).to_i / 365
    end
  end

  def adult?
    date_of_birth && age >= 18
  end

  def child?
    date_of_birth && age < 18
  end
end
