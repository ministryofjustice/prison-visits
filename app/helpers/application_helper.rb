module ApplicationHelper
  def display_time_slot(times, glue=' to ')
    from, to = times.split('-')
    [format_time_str(from), format_time_str(to)].join(glue)
  end

  def display_slot_and_duration(times, glue=', ')
    from, to = times.split('-')
    [format_time_str(from), (time_from_str(to)-time_from_str(from)).duration].join(glue)
  end

  def format_time_str(time)
    time_from_str(time).strftime("%l:%M%P")
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
