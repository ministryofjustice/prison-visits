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
  attribute :works_weekends, Boolean,
    default: false,
    lazy: true

  class PrisonNotFound < StandardError; end

  def self.all
    Rails.configuration.prisons
  end

  def self.create(opts = {})
    new(opts).tap { |p| Rails.configuration.prisons << p }
  end

  def self.enabled
    all.select(&:enabled)
  end

  def self.find(name_or_nomis)
    all.detect { |p|
      p.name == name_or_nomis || p.nomis_id == name_or_nomis
    }
  end

  def initialize(opts = {})
    self.attributes = attributes.merge(opts.symbolize_keys)
  end

  def self.names
    all.map(&:name).sort
  end

  def self.nomis_ids
    all.map(&:nomis_id).compact.sort
  end

  def anomalous_dates
    (slot_anomalies || {}).keys.to_set
  end

  alias_method :days_lead_time, :lead_days

  def postcode
    address.last
  end

  def unbookable_dates
    (unbookable || []).to_set
  end

  alias_method :visiting_slots, :slots

  def visiting_slot_days
    visiting_slots.keys
  end

  alias_method :works_everyday?, :works_weekends?
end
