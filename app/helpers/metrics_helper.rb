module MetricsHelper
  SECONDS_PER_DAY = 24 * 60 * 60
  SECONDS_PER_HOUR = 60 * 60
  SECONDS_PER_MINUTE = 60

  def display_interval(seconds)
    return unless seconds

    left = seconds
    days = left / SECONDS_PER_DAY
    left -= days * SECONDS_PER_DAY

    hours = left / SECONDS_PER_HOUR
    left -= hours * SECONDS_PER_HOUR

    minutes = left / SECONDS_PER_MINUTE
    left -= minutes * SECONDS_PER_MINUTE

    seconds = left

    {d: days, h: hours, m: minutes}.inject("") do |s, (abbr, value)|
      value > 0 ? s + "#{value}#{abbr}" : s
    end + "#{seconds}s"
  end

  def display_percent(value)
    return if value.nil? || value.nan?

    sprintf("%.1f%%", value * 100)
  end
end
