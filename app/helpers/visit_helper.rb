module VisitHelper
  def visiting_slots
    prison_data['slots'].inject({}) do |hash, (day, slots)|
      hash.merge({
        day.to_sym => slots.map { |s| s.split('-') }
      })
    end
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
    source.prisoner.prison
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
end
