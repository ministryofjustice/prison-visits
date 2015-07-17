class PrisonDay < Struct.new(:date, :prison)
  BANK_HOLIDAYS = Rails.configuration.bank_holidays.dup
  WEEKEND_DAYS = %w<sat sun>.freeze

  def staff_working_day?
    non_holiday? && working_day?
  end

  private

  delegate :works_everyday?, to: :prison

  def working_day?
    works_everyday? ? true : weekday?
  end

  def weekday?
    WEEKEND_DAYS.exclude? abbreviated_day_name
  end

  def non_holiday?
    BANK_HOLIDAYS.exclude? date
  end

  def abbreviated_day_name
    date.strftime('%a').downcase
  end
end
