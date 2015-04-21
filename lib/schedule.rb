class Schedule
  WEEK_DAYS_MAP = { sun: 0, mon: 1, tue: 2, wed: 3, thu: 4, fri: 5, sat: 6 }.invert
  DEFAULT_BOOKING_WINDOW = 28 # days
  DEFAULT_LEAD_DAYS = 3 # days

  def initialize(prison_data_for_prison, bank_holidays)
    @unbookable_dates = (prison_data_for_prison[:unbookable] || []).to_set
    @visiting_slots = prison_data_for_prison[:slots] || {}
    @anomalous_dates = (prison_data_for_prison[:slot_anomalies] || {}).keys
    @works_weekends = prison_data_for_prison[:works_weekends]
    @lead_days = prison_data_for_prison[:lead_days] || DEFAULT_LEAD_DAYS
    @booking_window = prison_data_for_prison[:booking_window] || DEFAULT_BOOKING_WINDOW
    @bank_holidays = bank_holidays
  end

  def dates(starting_when)
    except_lead_days(starting_when, except_days_without_slots(except_unbookable(booking_range(starting_when))))
  end

  def except_unbookable(enumerable)
    Enumerator.new do |e|
      enumerable.each do |current|
        e.yield(current) unless @unbookable_dates.include? current
      end
    end
  end

  def except_days_without_slots(enumerable)
    Enumerator.new do |e|
      enumerable.each do |current|
        e.yield(current) if @visiting_slots[WEEK_DAYS_MAP[current.wday]] || @anomalous_dates.include?(current)
      end
    end
  end

  def except_lead_days(start_date, enumerable)
    lead_days = @lead_days

    if lead_days == 0
      offsets = {
        0 => 0,
        1 => 0,
        2 => 0,
        3 => 0,
        4 => 0,
        5 => 2,
        6 => 1
      }
    else
      offsets = {
        0 => lead_days,
        1 => lead_days,
        2 => lead_days,
        3 => lead_days + 2,
        4 => lead_days + 2,
        5 => lead_days + 2,
        6 => lead_days + 1
      }
    end

    offset = offsets[start_date.wday]

    Enumerator.new do |e|
      enumerable.each do |current|
        if @bank_holidays.include? current
          lead_days += 1
          offset += 1
        end

        since_start_date = (current - start_date).to_i

        if @works_weekends
          e.yield(current) if since_start_date > lead_days
        else
          e.yield(current) if since_start_date > offset
        end
      end
    end
  end

  def booking_range(starting_when)
    starting_when..(starting_when + @booking_window)
  end
end

