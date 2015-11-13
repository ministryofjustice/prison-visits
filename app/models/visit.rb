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

  validates :visit_id, presence: true
  validates :slots, length: {
    in: 1..MAX_SLOTS,
    on: :date_and_time
  }
  validate :validate_amount_of_adults, on: :visitors_set

  delegate :prison, :prison_name, :prison_name=,
    to: :prisoner, allow_nil: true
  delegate :prison_email, :prison_nomis_id,
    to: :prisoner
  delegate :adult_age, to: :prison

  def validate_amount_of_adults
    if visitors.none? { |v| adult?(v) }
      errors.add :visitors, :at_least_one_adult
    end
    if visitors.count { |v| adult?(v) } > 3
      errors.add :visitors, :max_3_adults, adult_age: adult_age
    end
  end

  def adult?(visitor)
    visitor.age && visitor.age >= adult_age
  end

  def same_visit?(other)
    other.visit_id == self.visit_id
  end

  def prisoner?
    prisoner.present?
  end

  def prisoner_number?
    prisoner? && prisoner.number.present?
  end

  def prison_name?
    prisoner? && prisoner.prison_name.present?
  end

  def prison?
    prisoner && prison.present?
  end

  def prison_slots?
    prison? && prison.slots.present?
  end
end
