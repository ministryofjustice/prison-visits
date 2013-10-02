module ApplicationHelper
  def display_time_slot(times, glue=' to ')
    from, to = times.split('-')
    [format_time_str(from), format_time_str(to)].join(glue)
  end

  def format_time_str(time)
    Time.strptime(time, '%H%M').strftime("%l:%M%P")
  end
end
