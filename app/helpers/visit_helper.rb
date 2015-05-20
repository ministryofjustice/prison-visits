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
    Rails.configuration.prison_data.fetch(source.prisoner.prison_name.to_s)
  end

  def prison_name(source=visit)
    source.prisoner.prison_name
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

  def adult_age
    prison_data['adult_age'] || 18
  end

  def prison_url(visit)
    data = prison_data(visit)
    slug = data['finder_slug'] ? data['finder_slug'] : visit.prisoner.prison_name.parameterize
    ['http://www.justice.gov.uk/contacts/prison-finder', slug].join('/')
  end

  def prison_link(source=visit, link_text=nil)
    link_text = link_text ? link_text : "#{source.prisoner.prison_name.capitalize} prison"
    link_to link_text, prison_url(visit), :rel => 'external'
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

  def when_to_expect_reply(today=Date.today)
    schedule = Schedule.new(prison_data, Rails.configuration.bank_holidays)
    format_day(schedule.except_lead_days(today, schedule.booking_range(today)).first)
  end

  def custom_id_requirements(prison_name, format)
    nomis_id = Rails.configuration.prison_data[prison_name][:nomis_id]
    label = "id_#{nomis_id}"
    template = lookup_context.find_template(label, 'content', true)
    case format
    when :html
      render File.join('content', label)
    when :text
      File.read(template.identifier)
    end
  rescue ActionView::MissingTemplate
    nil
  end

  def standard_id_requirements(format)
    template = lookup_context.find_template('standard_id_requirements', 'content', true)
    case format
    when :html
      template.render(nil, nil)
    when :text
      File.read(template.identifier)
    end
  end

  def weeks_start
    Date.today.beginning_of_week
  end

  def weeks_end
    (Date.today + Slot::BOOKABLE_DAYS.days).end_of_month.end_of_week
  end

  def weeks
    (weeks_start..weeks_end).group_by do |day|
      day.beginning_of_week
    end
  end

  def tag_with_today?(day)
    day == Date.today
  end

  def tag_with_month?(day)
    day.beginning_of_month == day
  end

  def last_initial(name, glue=';')
    last_name(name, glue).chars.first.upcase + '.'
  end

  def first_name(name, glue=';')
    name.split(glue).first
  end

  def last_name(name, glue=';')
    name.split(glue)[1]
  end

  def visitor_names(visitors)
    visitors.inject([]) do |arr, visitor|
      arr << visitor.full_name(';')
    end
  end
end
