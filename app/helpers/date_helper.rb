module DateHelper
  def format_date_of_birth(date)
    I18n.l(date_from_string_or_date(date), format: :date_of_birth)
  end

  def format_date_of_visit(date)
    I18n.l(date_from_string_or_date(date), format: :date_of_visit)
  end

  def format_time_12hr(time)
    I18n.l(time_from_string(time), format: :twelve_hour)
  end

  def format_time_24hr(time)
    I18n.l(time_from_string(time), format: :twenty_four_hour)
  end

  def format_start_time(times)
    format_time_12hr(times.split('-')[0])
  end

  def format_slot_and_duration(times, glue = ' for ')
    from, to = times.split('-')
    [
      format_start_time(times),
      (time_from_string(to) - time_from_string(from)).duration
    ].join(glue)
  end

  private

  def date_from_string_or_date(obj)
    if obj.is_a?(String)
      Date.parse(obj)
    else
      obj
    end
  end

  def time_from_string(obj)
    Time.strptime(obj, '%H%M')
  end
end
