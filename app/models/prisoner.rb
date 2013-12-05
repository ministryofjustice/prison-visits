class Prisoner
  include ActiveModel::Model

  PRISONS = [
    'Rochester',
  ].sort

  PRISON_DETAILS = {
    cardiff: {
      phone: '-phone missing-',
      email: '-email missing-'
    },
    durham: {
      phone: '-phone missing-',
      email: '-email missing-'
    },
    :gartree => {
      phone: '01858 426 600',
      email: 'socialvisits.gartree@hmps.gsi.gov.uk'
    },
    rochester: {
      phone: '01634 803100',
      email: 'socialvisits.rochester@hmps.gsi.gov.uk'
    }
  }

  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :number
  attr_accessor :prison_name
  attr_accessor :date_of_birth

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :date_of_birth
  validates_inclusion_of :date_of_birth, in: ->(_) { 100.years.ago..Time.now }, if: ->(p) { p.date_of_birth }, message: "must be a valid date of birth"
  validates_format_of :number, with: /\A[a-z]\d{4}[a-z]{2}\z/i, message: "must be a valid prisoner number" # eg a1234aa
  validates_inclusion_of :prison_name, in: PRISONS

  def full_name
    [@first_name, @last_name].join(' ')
  end

  def age
    if date_of_birth
      (Date.today - date_of_birth.to_date).to_i / 365
    end
  end
end
