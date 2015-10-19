class GoogleAnalyticsAdapter
  def initialize(visit)
    @visit = visit
  end

  def to_json
    {
      prison_name: prison_name,
      number_of_slots: number_of_slots,
      prisoner_age: prisoner_age,
      visitor_age: visitor_age,
      number_of_adult_visitors: number_of_adult_visitors,
      number_of_child_visitors: number_of_child_visitors,
      slot_times: slot_times,
      slot_weekdays: slot_weekdays,
      days_to_first_slot: days_to_first_slot,
      days_to_last_slot: days_to_last_slot,
      completed_at: Time.now.utc.strftime("%Y%m%d%H%M%S")
    }.to_json
  end

  private

  def prison_name
    @visit.prison_name
  end

  def number_of_slots
    date_sorted_slots.count
  end

  def slot_times
    date_sorted_slots.map(&:times)
  end

  def slot_weekdays
    date_sorted_slots.map(&:weekday)
  end

  def prisoner_age
    @visit.prisoner.age
  end

  def visitor_age
    @visit.visitors.first.age
  end

  def number_of_adult_visitors
    @visit.visitors.count { |v| @visit.adult?(v) }
  end

  def number_of_child_visitors
    @visit.visitors.count { |v| !@visit.adult?(v) }
  end

  def days_to_first_slot
    number_of_days_from_now_for date_sorted_slots.first
  end

  def days_to_last_slot
    number_of_days_from_now_for date_sorted_slots.last
  end

  def number_of_days_from_now_for(slot)
    (Date.parse(slot.date) - Date.today).to_i if slot
  end

  def date_sorted_slots
    @visit.slots.reject { |s| s.date.nil? || s.date.empty? }.sort_by(&:date)
  end
end
