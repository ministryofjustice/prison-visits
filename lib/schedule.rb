class Schedule
  WEEK_DAYS_MAP = { sun: 0, mon: 1, tue: 2, wed: 3, thu: 4, fri: 5, sat: 6 }.invert

  def initialize(prison_data_for_prison)
    @unbookable_dates = prison_data_for_prison[:unbookable].to_set
    @visiting_slots = prison_data_for_prison[:slots]
    @anomalous_dates = (prison_data_for_prison[:slot_anomalies] || {}).keys
  end

  def dates(starting_when, how_many_days)
    except_lead_days(starting_when, 3, except_days_without_slots(except_unbookable(starting_when..(starting_when + how_many_days))))
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

  def except_lead_days(start_date, lead_days, enumerable)
    Enumerator.new do |e|
      enumerable.each do |current|
        e.yield(current) unless current < start_date + lead_days
      end
    end
  end
end

