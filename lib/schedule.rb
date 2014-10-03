class Schedule
  WEEK_DAYS_MAP = { sun: 0, mon: 1, tue: 2, wed: 3, thu: 4, fri: 5, sat: 6 }.invert

  def initialize(prison_data_for_prison)
    @unbookable_dates = prison_data_for_prison[:unbookable].to_set
    @visiting_slots = prison_data_for_prison[:slots]
    @anomalous_dates = (prison_data_for_prison[:slot_anomalies] || {}).keys
    @works_weekends = prison_data_for_prison[:works_weekends]
    @lead_days = prison_data_for_prison[:lead_days] || 3
  end

  def dates(starting_when, how_many_days)
    except_lead_days(starting_when, @lead_days, except_days_without_slots(except_unbookable(starting_when..(starting_when + how_many_days))))
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
    Enumerator.new do |e|
      enumerable.each do |current|
        if @works_weekends
          e.yield(current) if current - start_date > lead_days
        else
          e.yield(current) if current - start_date > offsets[start_date.wday]
        end
      end
    end
  end
end

