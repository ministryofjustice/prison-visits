class AgeValidator < ActiveModel::Validator
  DEFAULT_ADULT_AGE = 18

  def initialize(prison_config)
    @config = prison_config || (raise ArgumentError)
    super
  end

  def validate(record)
    if date_of_birth = record.date_of_birth.try(:to_date)
      subject_age = (Date.today - date_of_birth).to_i / 365
      record.errors.add(:date_of_birth, "You must be #{adult_age} or older to book a visit") if subject_age < adult_age
    end
  end

  def adult_age
    @config[:adult_age] || DEFAULT_ADULT_AGE
  end
end
