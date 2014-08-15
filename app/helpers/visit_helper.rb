module VisitHelper
  def visiting_slots
    prison_data['slots'].inject({}) do |hash, (day, slots)|
      hash.merge({
        day.to_sym => slots.map { |s| s.split('-') }
      })
    end
  end

  def lead_days
    1 + (prison_data['lead_days'] || Slot::LEAD_DAYS)
  end

  def work_weekends?
    prison_data['work_weekends'] || false
  end

  def unbookable_dates
    prison_data['unbookable'] || []
  end

  def bookable_from(day=Date.today)
    date = day + lead_days
    date = skip_weekend date unless work_weekends?
  end

  def skip_weekend(date)
    case date.wday
    when 6
      return date + 2
    when 0
      return date + 1
    else
      return date
    end
  end

  def weekend_days_in_range(range)
    range.select{ |d| [0, 6].include?(d.wday) }.size
  end

  def exclude_weekends(from, days)
    from = skip_weekend from
    to = from + days
    extra = weekend_days_in_range(from..to)
    if extra > 0
      extra = extra - 2 if to.saturday?
      extra = extra - 1 if to.sunday?
      return exclude_weekends(to, extra)
    else
      return to
    end
  end

  def bookable_to
    Date.today + Slot::BOOKABLE_DAYS.days
  end

  def bookable_range
    bookable_from..bookable_to
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

  def prison_names
    Rails.configuration.prison_data.keys.sort
  end

  def prison_data(source=visit)
    Rails.configuration.prison_data[source.prisoner.prison_name.to_s]
  end

  def prison_phone
    prison_data['phone']
  end

  def prison_email
    prison_data['email']
  end

  def prison_email_link
    mail_to prison_data['email']
  end

  def prison_postcode
    prison_data['address'][-1]
  end

  def prison_slot_anomalies
    prison_data['slot_anomalies']
  end

  def prison_address(glue='<br>')
    prison_data['address'].join(glue).html_safe
  end

  def prison_url(visit)
    data = prison_data(visit)
    slug = data['finder_slug'] ? data['finder_slug'] : visit.prisoner.prison_name.parameterize
    ['http://www.justice.gov.uk/contacts/prison-finder', slug].join('/')
  end

  def prison_link(visit)
    link_to "#{visit.prisoner.prison_name.capitalize} prison", prison_url(visit), :rel => 'external'
  end

  def has_anomalies?(day)
    prison_slot_anomalies && prison_slot_anomalies.keys.include?(day)
  end

  def anomalies_for_day(day)
    return prison_slot_anomalies[day].map do |slot|
      slot.split('-')
    end
  end

  def slots_for_day(day)
    if has_anomalies? day
      return anomalies_for_day day
    else
      return visiting_slots[day.strftime('%a').downcase.to_sym]
    end
  end

  def day_is_bookable(day)
    visiting_slots.keys.include?(day.strftime('%a').downcase.to_sym) && !unbookable_dates.include?(day)
  end
end
