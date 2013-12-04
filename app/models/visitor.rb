class Visitor
  include ActiveModel::Model

  USER_MIN_AGE = 18

  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :email
  attr_accessor :phone
  attr_accessor :index
  attr_accessor :type
  attr_accessor :number_of_adults
  attr_accessor :number_of_children
  attr_reader :date_of_birth

  def date_of_birth=(dob_string)
    @date_of_birth = Date.parse(dob_string)
  rescue ArgumentError, TypeError
    @date_of_birth = dob_string
    errors.add(:date_of_birth, 'is invalid')
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  validates_presence_of :first_name
  validates_presence_of :last_name
  validate :validate_user_or_additional

  def validate_user_or_additional
    if index.zero?
      errors.add(:email, 'must be given') unless email.present? && email.size > 5
      errors.add(:phone, 'must be given and include area code') unless phone.present? && phone.size > 10
      errors.add(:date_of_birth, 'You must be over 18 years old to book a visit') unless date_of_birth.present? && date_of_birth < 18.years.ago
    else
      errors.add(:email, 'must not be given') if email.present?
      errors.add(:phone, 'must not be given') if phone.present?
      errors.add(:type, 'must be given') unless type.present?
    end
  end

  def age
    if date_of_birth
      (Date.today - date_of_birth).to_i / 365
    end
  end

  def adult?
    date_of_birth && age >= 18 || type == 'adult'
  end

  def child?
    date_of_birth && age < 18 || type == 'child'
  end
end
