class Visitor
  include ActiveModel::Model

  USER_MIN_AGE = 18

  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :email
  attr_accessor :phone
  attr_accessor :index
  attr_reader :date_of_birth
  def date_of_birth=(dob_string)
    @date_of_birth = Date.parse(dob_string)
  rescue
    errors.add(:date_of_birth, 'is invalid')
  end

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_length_of :phone, minimum: 10, allow_blank: true
  validates_inclusion_of :date_of_birth, in: ->(_) { Date.new(1850, 1, 1)..Date.today }

  validate do
    if index == 0
      errors.add(:email, 'Must be given') unless email.present? && email.size > 5
    else
      errors.add(:email, 'Must not be given') if email.present?
    end
  end

  def compactable?
    if index == 0
      first_name.present? && last_name.present? && date_of_birth.present? && email.present?
    else
      first_name.present? && last_name.present? && date_of_birth.present?
    end
  end
end
