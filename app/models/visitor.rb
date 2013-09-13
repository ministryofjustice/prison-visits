class Visitor
  include ActiveModel::Model

  attr_accessor :given_name
  attr_accessor :surname
  attr_accessor :email
  attr_accessor :phone
  attr_reader :date_of_birth
  def date_of_birth=(dob_string)
    @date_of_birth = Date.parse(dob_string)
  rescue
    errors.add(:date_of_birth, 'is invalid')
  end

  validates_length_of :given_name, minimum: 1
  validates_length_of :surname, minimum: 1
  validates_length_of :email, minimum: 5, allow_blank: true
  validates_length_of :phone, minimum: 10, allow_blank: true
  validates_inclusion_of :date_of_birth, in: ->(_) { Date.new(1850, 1, 1)..Date.today }
end
