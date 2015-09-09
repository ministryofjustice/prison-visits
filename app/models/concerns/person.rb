module Person
  extend ActiveSupport::Concern

  MAX_AGE = 120

  included do
    attribute :first_name, String
    attribute :last_name, String
    attribute :date_of_birth, Date

    validates :first_name, presence: true, name: true
    validates :last_name, presence: true, name: true
    validates :date_of_birth,
      presence: true,
      inclusion: {
        in: ->(_) { MAX_AGE.years.ago.beginning_of_year.to_date..Time.zone.today }
      }
  end

  def full_name(glue=' ')
    [first_name, last_name].join(glue)
  end

  def last_initial
    last_name.chars.first.upcase
  end

  def age
    return nil unless date_of_birth
    AgeCalculator.new.age(date_of_birth)
  end
end
