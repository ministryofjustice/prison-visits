class PrisonDay < Struct.new(:date, :prison)
  BANK_HOLIDAYS = Rails.configuration.bank_holidays.dup
  WEEKEND_DAYS = %w<sat sun>.freeze

  def staff_working_day?
    non_holiday? && working_day?
  end

  def visiting_day?
    non_blocked_day? && non_holiday? && available_day?
  end

  private

  delegate :works_everyday?, :anomalous_dates,
    :visiting_slot_days, :unbookable_dates, to: :prison

  def working_day?
    works_everyday? ? true : weekday?
  end

  def weekday?
    WEEKEND_DAYS.exclude? abbreviated_day_name
  end

  def non_holiday?
    BANK_HOLIDAYS.exclude? date
  end

  def anomalous_day?
    anomalous_dates.include? date
  end

  def visiting_slot?
    visiting_slot_days.include? abbreviated_day_name
  end

  def available_day?
    visiting_slot? || anomalous_day?
  end

  def non_blocked_day?
    unbookable_dates.exclude? date
  end

  def abbreviated_day_name
    date.strftime('%a').downcase
  end
end
