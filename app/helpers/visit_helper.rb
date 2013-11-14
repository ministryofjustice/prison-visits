module VisitHelper
  def year_limit(index)
    index.zero? ? Visitor::USER_MIN_AGE : 0
  end

  def dob_year_range(index)
    100.years.ago.strftime('%Y').to_i..year_limit(index).years.ago.strftime('%Y').to_i
  end

  def dob_month_range
    (Date.today.beginning_of_year..Date.today.end_of_year).group_by do |date|
      date.beginning_of_month
    end
  end

  def dob_day_range
    dec = Date.parse('2013-12-01')
    dec.beginning_of_month..dec.end_of_month
  end

  def select_year(dob, year, default=0)
    if dob.present?
      if dob.strftime('%Y').to_i == year
        return 'selected'
      end
    elsif default.years.ago.strftime('%Y').to_i == year
      return 'selected'
    end
  end

  def visiting_slots
    Slot::TIMES[visit.prisoner.prison_name.downcase.to_sym]
  end

  def bookable_from
    Date.tomorrow + Slot::LEAD_DAYS
  end

  def bookable_to
    Date.today + Slot::BOOKABLE_DAYS.days
  end

  def bookable_range
    bookable_from..bookable_to
  end

  def range_by_month
    bookable_range.group_by do |date|
      date.beginning_of_month
    end
  end

  def number_of_slots
    Visit::MAX_SLOTS
  end

  def bookable_week_days
    { sun: 0, mon: 1, tue: 2, wed: 3, thu: 4, fri: 5, sat: 6 }.keep_if do |key, value|
      visiting_slots.keys.include?(key) 
    end.values
  end

  def current_slots
    visit.slots.map do |slot|
      slot.date + '-' + slot.times
    end
  end

  def bookable_dates
    bookable_range.map do |date|
      date.strftime('%Y-%m-%d')
    end
  end
end
