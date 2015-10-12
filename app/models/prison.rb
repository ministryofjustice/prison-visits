class Prison
  include Virtus.model

  DEFAULT_ADULT_AGE =       18
  DEFAULT_BOOKING_WINDOW =  28
  DEFAULT_LEAD_DAYS =       3

  attribute :address
  attribute :adult_age, Integer,
    default: DEFAULT_ADULT_AGE,
    lazy: true
  attribute :booking_window, Integer,
    default: DEFAULT_BOOKING_WINDOW,
    lazy: true
  attribute :canned_responses, Boolean
  attribute :email, String
  attribute :enabled, Boolean
  attribute :finder_slug, String
  attribute :lead_days, Integer,
    default: DEFAULT_LEAD_DAYS,
    lazy: true
  attribute :name, String
  attribute :nomis_id, String
  attribute :phone, String
  attribute :reason
  attribute :slot_anomalies
  attribute :slots
  attribute :unbookable, Boolean
  attribute :works_weekends, Boolean, default: false, lazy: true

  class PrisonNotFound < StandardError; end

  def self.find(name_or_nomis, raise_error = false)
    prison = all.detect { |p|
      p.name == name_or_nomis || p.nomis_id == name_or_nomis
    }
    if raise_error && prison.nil?
      raise PrisonNotFound, "Can't find prison #{name_or_nomis.inspect}"
    end
    prison
  end

  def initialize(opts = {})
    self.attributes = attributes.merge(opts.symbolize_keys)
  end

  def self.create(opts = {})
    prison = new(opts)
    Rails.configuration.prisons << prison
    prison
  end

  def self.all
    Rails.configuration.prisons
  end

  def self.enabled
    all.select{ |p| p.enabled == true }
  end

  def self.names
    all.map(&:name).sort
  end

  def self.nomis_ids
    all.map(&:nomis_id).compact.sort
  end

  def unbookable_dates
    (unbookable || []).to_set
  end

  def visiting_slots
    @visiting_slots = slots
  end

  def visiting_slot_days
    visiting_slots.keys
  end

  def anomalous_dates
    (slot_anomalies || {}).keys.to_set
  end

  def days_lead_time
    lead_days
  end

  def works_weekends?
    works_weekends || false
  end
  alias_method :works_everyday?, :works_weekends?
end
