class AgeValidator < ActiveModel::Validator
  attr_accessor :adult_age

  def initialize(prison)
    @adult_age = prison.adult_age
  end

  def validate(record)
    return unless record.date_of_birth
    age = AgeCalculator.new.age(record.date_of_birth)
    if age < adult_age
      record.errors.add :date_of_birth,
        "You must be #{adult_age} or older to book a visit"
    end
  end
end
