class Prison
  DEFAULT_LEAD_DAYS = 3.freeze
  DEFAULT_BOOKING_WINDOW = 28.freeze

  class PrisonNotFound < StandardError; end

  def self.find(prison_name)
    prison_hash = Rails.configuration.prison_data[prison_name]
    raise PrisonNotFound if prison_hash.nil?
    new(prison_name, prison_hash)
  end

  def initialize(name, prison_hash)
    @name = name
    @prison_hash = prison_hash.with_indifferent_access
  end

  attr_reader :name

  delegate :fetch, to: :@prison_hash

  def unbookable_dates
    (fetch(:unbookable) { Array.new }).to_set
  end

  def visiting_slots
    fetch(:slots)
  end

  def visiting_slot_days
    visiting_slots.keys
  end

  def anomalous_dates
    (fetch(:slot_anomalies) { Hash.new }).keys.to_set
  end

  def days_lead_time
    fetch(:lead_days, DEFAULT_LEAD_DAYS)
  end

  def booking_window
    fetch(:booking_window, DEFAULT_BOOKING_WINDOW)
  end

  def works_weekends?
    fetch(:works_weekends, false)
  end
  alias_method :works_everyday?, :works_weekends?
end
