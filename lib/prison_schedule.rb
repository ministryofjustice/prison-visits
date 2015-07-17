class PrisonSchedule < Struct.new(:prison)

  delegate :days_lead_time, :booking_window, to: :prison

  def confirmation_email_date
    staff_working_days.take(days_lead_time).last
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
    confirmation_email_range.lazy.each do |day|
      day if PrisonDay.new(day, prison).staff_working_day?
    end
  end

  def confirmation_email_range
    Date.tomorrow..prison_booking_window_in_days
  end

  def available_visitation_range
    day_after_confirmation_email..prison_booking_window_in_days
  end

  def day_after_confirmation_email
     confirmation_email_date.tomorrow
  end

  def prison_booking_window_in_days
    booking_window.days.from_now
  end
end
