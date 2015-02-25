class GoogleAnalyticsAdapter
  def initialize(visit)
    @visit = visit
  end

  def prison_name
    @visit.prisoner.prison_name
  end

  def number_of_slots
    nonempty_slots.count
  end

  def slot_times
    nonempty_slots.map { |s| s.times }
  end

  def slot_weekdays
    nonempty_slots.map { |s| s.weekday }
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

  def nonempty_slots
    @visit.slots.reject { |s| s.date.nil? || s.date.empty? }
  end

  def days_to_first_slot
    if slot = nonempty_slots.sort_by { |s| s.date }.first
      (Date.parse(slot.date) - Date.today).to_i
    end
  end

  def days_to_last_slot
    if slot = nonempty_slots.sort_by { |s| s.date }.last
      (Date.parse(slot.date) - Date.today).to_i
    end
  end

  def as_json
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
    }
  end

  def to_json
    as_json.to_json
  end
end
