class Visit
  include ActiveModel::Model

  MAX_VISITORS = 6
  MAX_ADULTS = 3
  MAX_SLOTS = 3

  attr_accessor :prisoner
  attr_accessor :visitors
  attr_accessor :slots

  validates_size_of :visitors, within: 1..MAX_VISITORS, on: :visitors_set
  validates_size_of :adult_visitors, within: 1..MAX_ADULTS, on: :visitors_set, message: "must be between 1 and #{MAX_ADULTS}"
  validates_size_of :slots, within: 1..MAX_SLOTS, on: :date_and_time, message: 'must be at least one and at most three'

  def adult_visitors
    visitors.select { |v| v.adult? }
  end
end
