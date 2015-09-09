class AgeValidator < ActiveModel::Validator
  DEFAULT_ADULT_AGE = 18

  def initialize(prison_config)
    @config = prison_config || (raise ArgumentError)
    super
  end

  def validate(record)
    return unless record.date_of_birth
    age = AgeCalculator.new.age(record.date_of_birth)
    if age < adult_age
      record.errors.add :date_of_birth,
        "You must be #{adult_age} or older to book a visit"
    end
  end

  def adult_age
    @config[:adult_age] || DEFAULT_ADULT_AGE
  end
end
