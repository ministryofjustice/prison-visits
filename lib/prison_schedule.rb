class PrisonSchedule < Struct.new(:prison)

  delegate :days_lead_time, :booking_window, to: :prison

  def confirmation_email_date
    staff_working_days.take(prison_processing_days).last
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
    Date.today..last_bookable_day
  end

  def available_visitation_range
    confirmation_email_date.next_day..last_bookable_day
  end

  def last_bookable_day
    booking_window.days.from_now.to_date
  end

  def prison_processing_days
    # increment the value as `#take` on a range is not zero based
    days_lead_time.next
  end
end
