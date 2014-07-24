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
    prison_data['slots'].inject({}) do |hash, (day, slots)|
      hash.merge({
        day.to_sym => slots.map { |s| s.split('-') }
      })
    end
  end

  def unbookable_dates
    prison_data['unbookable'] || []
  end

  def bookable_from
    Date.today + Slot::LEAD_DAYS
  end

  def bookable_to
    Date.today + Slot::BOOKABLE_DAYS.days
  end

  def bookable_range
    bookable_from..bookable_to
  end

  def bookable_range_with_buffer(buffer)
    (bookable_from - buffer.days)..(bookable_to + buffer.days)
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
