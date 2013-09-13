class Prisoner
  include ActiveModel::Model

  PRISONS = [
    'HMP Gartree',
    'HMP Rochester',
    'HMP Cardiff',
    'HMP Durham'
  ]

  attr_accessor :given_name
  attr_accessor :surname
  attr_accessor :date_of_birth
  attr_accessor :number
  attr_accessor :prison_name

  validates_length_of :given_name, minimum: 1
  validates_length_of :surname, minimum: 1
  validates_inclusion_of :date_of_birth, in: ->(_) { Date.new(1850, 1, 1)..Date.today }
  validates_format_of :number, with: /\d+/
  validates_inclusion_of :prison_name, in: PRISONS
end
