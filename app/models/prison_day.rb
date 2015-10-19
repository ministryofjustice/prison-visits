class PrisonDay
  attr_accessor :date, :prison

  def initialize(date, prison)
    @date = date
    @prison = prison
  end

  WEEKEND_DAYS = %w[ sat sun ].freeze

  def staff_working_day?
    normal_working_day? && !holiday?
  end

  def visiting_day?
    available_day? && !blocked_day?
  end

  private

  delegate :works_everyday?, :anomalous_dates,
    :visiting_slot_days, :unbookable_dates, to: :prison

  def normal_working_day?
    works_everyday? ? true : weekday?
  end

  def weekday?
    WEEKEND_DAYS.exclude? abbreviated_day_name
  end

  def holiday?
    Rails.configuration.bank_holidays.include?(date)
  end

  def anomalous_day?
    anomalous_dates.include? date
  end

  def visiting_slot?
    visiting_slot_days.include?(abbreviated_day_name) && !holiday?
  end

  def available_day?
    visiting_slot? || anomalous_day?
  end

  def blocked_day?
    unbookable_dates.include?(date)
  end

  def abbreviated_day_name
    date.strftime('%a').downcase
  end
end
