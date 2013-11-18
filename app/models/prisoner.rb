class Prisoner
  include ActiveModel::Model

  PRISONS = [
    'Gartree',
    'Rochester',
    'Cardiff',
    'Durham'
  ].sort

  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :number
  attr_accessor :prison_name

  attr_reader :date_of_birth
  def date_of_birth=(dob_string)
    @date_of_birth = Date.parse(dob_string)
  rescue
    @date_of_birth = nil
    errors.add(:date_of_birth, 'invalid date')
  end

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_inclusion_of :date_of_birth, in: ->(_) { 100.years.ago.to_date..Date.today }, message: "must be a valid date of birth"
  validates_format_of :number, with: /\A[a-z]\d{4}[a-z]{2}\z/i, message: "must be a valid prisoner number" # eg a1234aa
  validates_inclusion_of :prison_name, in: PRISONS
end
