class Visitor
  include ActiveModel::Model

  attr_accessor :full_name
  attr_accessor :email
  attr_accessor :phone
  attr_accessor :index

  attr_reader :date_of_birth
  def date_of_birth=(dob_string)
    @date_of_birth = Date.parse(dob_string)
  rescue
    errors.add(:date_of_birth, 'is invalid')
  end

  validates_presence_of :full_name
  validates_length_of :phone, minimum: 10, allow_blank: true
  validates_inclusion_of :date_of_birth, in: ->(_) { Date.new(1850, 1, 1)..Date.today }

  validate do
    if index == 0
      errors.add(:email, 'Must be given') unless email.present? && email.size > 5
    else
      errors.add(:email, 'Must not be given') if email.present?
    end
  end
end
