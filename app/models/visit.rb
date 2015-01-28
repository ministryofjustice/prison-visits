class Visit
  include ActiveModel::Model

  MAX_VISITORS = 6
  MAX_ADULTS = 3
  MAX_SLOTS = 3

  attr_accessor :prisoner
  attr_accessor :visitors
  attr_accessor :slots
  attr_accessor :visit_id
  attr_accessor :vo_number

  validates_presence_of :visit_id
  validates_size_of :slots, within: 1..MAX_SLOTS, on: :date_and_time, message: 'must be at least one and at most three'
  validate :validate_amount_of_adults, on: :visitors_set

  def validate_amount_of_adults
    errors.add(:base, "There must be at least one adult visitor") unless visitors.any? { |v| v.age && v.age >= 18 }
    errors.add(:base, "There can be at most three non-child visitors") if visitors.count { |v| v.age && v.age >= adult_age } > 3
  end

  def adult_age
    AgeValidator.new(Rails.configuration.prison_data[prisoner.prison_name]).adult_age
  end

  def adult?(visitor)
    visitor.age && visitor.age >= adult_age
  end
end
