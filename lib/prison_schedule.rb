class PrisonSchedule < Struct.new(:prison)

  delegate :days_lead_time, :booking_window, to: :prison

  def confirmation_email_date
    staff_working_days.take(prison_processing_days).last
  end

  def available_visitation_dates
    available_visitation_range.select { |day|
      PrisonDay.new(day, prison).visiting_day?
    }
  end

  private

  def staff_working_days
    confirmation_email_range.select { |day|
      PrisonDay.new(day, prison).staff_working_day?
    }
  end

  def confirmation_email_range
    # Use an arbitary number of days to apply the filter on
    Time.zone.tomorrow..last_bookable_day
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
