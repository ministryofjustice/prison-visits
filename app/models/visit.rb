class Visit
  include NonPersistedModel

  MAX_VISITORS = 6
  MAX_ADULTS = 3
  MAX_SLOTS = 3

  attribute :prisoner, Prisoner
  attribute :visitors, Array[Visitor]
  attribute :slots, Array[Slot]
  attribute :visit_id, String
  attribute :vo_number, String

  validates_presence_of :visit_id
  validates_size_of :slots, within: 1..MAX_SLOTS, on: :date_and_time, message: 'must be at least one and at most three'
  validate :validate_amount_of_adults, on: :visitors_set

  delegate :prison_name, :prison_name=, to: :prisoner, allow_nil: true

  def validate_amount_of_adults
    if visitors.none? { |v| v.age && v.age >= 18 }
      errors.add :base, "There must be at least one adult visitor"
    end
    if visitors.count { |v| v.age && v.age >= adult_age } > 3
      errors.add :base, "You can book a maximum of 3 visitors over the age of #{adult_age} on this visit"
    end
  end

  def adult_age
    AgeValidator.new(Rails.configuration.prison_data[prisoner.prison_name]).adult_age
  end

  def adult?(visitor)
    visitor.age && visitor.age >= adult_age
  end

  def same_visit?(other)
    other.visit_id == self.visit_id
  end
end
