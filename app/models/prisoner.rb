class Prisoner
  include ActiveModel::Model

  PRISONS = [
    'HMP Gartree',
    'HMP Rochester',
    'HMP Cardiff',
    'HMP Durham'
  ]

  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :number
  attr_accessor :prison_name

  attr_reader :date_of_birth
  def date_of_birth=(dob_string)
    @date_of_birth = Date.parse(dob_string)
  rescue
    errors.add(:date_of_birth, 'invalid date')
  end

  validates_length_of :first_name, minimum: 1
  validates_length_of :last_name, minimum: 1
  validates_inclusion_of :date_of_birth, in: ->(_) { Date.new(1850, 1, 1)..Date.today }
  validates_format_of :number, with: /\d+/
  validates_inclusion_of :prison_name, in: PRISONS
end
