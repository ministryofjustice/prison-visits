class Prison
  attr_accessor :address, :adult_age, :booking_window, :canned_responses,
    :email, :enabled, :finder_slug, :lead_days,
    :name, :nomis_id, :phone, :reason,
    :slot_anomalies, :slots, :unbookable,
    :works_weekends

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
  DEFAULT_BOOKING_WINDOW = 28.freeze

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
    opts.with_indifferent_access.map do |k, v|
      instance_variable_set("@#{k}", v)
    end
    @booking_window = DEFAULT_BOOKING_WINDOW if @booking_window.blank?
  end

  def self.create(opts = {})
    prison = new(opts)
    Rails.configuration.prison_data << prison
    prison
  end

  def self.all
    Rails.configuration.prison_data
  end

  def self.enabled
    all.select{ |p| p.enabled == true }
  end

  def self.names
    all.map(&:name).sort
  end

  def self.nomis_ids
    all.map(&:nomis_id).reject(&:nil?).sort
  end

  def enabled?
    enabled
  end

  def unbookable_dates
    (unbookable || Array.new).to_set
  end

  def visiting_slots
    @visiting_slots ||= slots
  end

  def visiting_slot_days
    visiting_slots.keys
  end

  def anomalous_dates
    (slot_anomalies || Hash.new).keys.to_set
  end

  def days_lead_time
    lead_days || DEFAULT_LEAD_DAYS
  end

  def works_weekends?
    works_weekends || false
  end
  alias_method :works_everyday?, :works_weekends?
end
