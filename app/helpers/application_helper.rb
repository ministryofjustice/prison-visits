module ApplicationHelper
  def format_date(string)
    Date.parse(string).strftime("%e %B %Y").strip
  end
  
  def display_time_slot(times, glue=' to ')
    from, to = times.split('-')
    [format_time_str(from).strip, format_time_str(to).strip].join(glue)
  end

  def display_slot_and_duration(times, glue=', ')
    from, to = times.split('-')
    [format_time_str(from).strip, (time_from_str(to)-time_from_str(from)).duration].join(glue)
  end

  def format_time_str(time)
    time_from_str(time).strftime("%l:%M%P").strip
  end

  def format_time_str_24(time)
    time_from_str(time).strftime("%H:%M").strip
  end

  def time_from_str(str)
    Time.strptime(str, '%H%M')
  end

  def page_title(header, glue=' - ')
    page_title = [Rails.configuration.app_title]
    page_title.unshift(header) if header.present?
    page_title.join glue
  end
end
