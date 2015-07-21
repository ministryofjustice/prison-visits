class PrisonSchedule < Struct.new(:prison)

  delegate :days_lead_time, :booking_window, to: :prison

  def confirmation_email_date
    @confirmation_email_date = staff_working_days.take(days_lead_time).last
  end

  def available_visitation_dates
    available_visitation_range.reduce([]) do |valid_dates, day|
      valid_dates.tap do |dates|
        dates << day if PrisonDay.new(day, prison).visiting_day?
      end
    end
  end

  private

  def staff_working_days
    Enumerator.new do |y|
      confirmation_email_range.each do |day|
        y << day if PrisonDay.new(day, prison).staff_working_day?
      end
    end
  end

  def confirmation_email_range
    # Use an arbitary number of days to apply the filter on
    Date.tomorrow..booking_window.days.from_now
  end

  def available_visitation_range
    day_after_confirmation_email..booking_window_days_later
  end

  def day_after_confirmation_email
    confirmation_email_date.tomorrow
  end

  def booking_window_days_later
    day_after_confirmation_email + booking_window.days
  end
end
