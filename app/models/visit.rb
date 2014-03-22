class Visit
  include ActiveModel::Model

  MAX_VISITORS = 6
  MAX_ADULTS = 3
  MAX_SLOTS = 3

  attr_accessor :prisoner
  attr_accessor :visitors
  attr_accessor :slots
  attr_accessor :visit_id

  validates_presence_of :visit_id
  validates_size_of :visitors, within: 1..MAX_VISITORS, on: :visitors_set
  validates_size_of :slots, within: 1..MAX_SLOTS, on: :date_and_time, message: 'must be at least one and at most three'
  validate :validate_amount_of_adults

  def validate_amount_of_adults
    errors.add(:base, "You can book for a maximum of 3 adults per visit") if adult_visitors.size > MAX_ADULTS
  end

  def adult_visitors
    visitors.select { |v| v.adult? }
  end
end
