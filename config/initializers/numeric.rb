class Numeric
  def duration
    secs  = self.to_int
    mins  = secs / 60
    hours = mins / 60
    duration = []

    if hours > 0
      hr = 'hr'.pluralize(hours)
      duration << "#{hours} #{hr}"
    end

    if mins % 60 > 0
      m = 'min'.pluralize(mins)
      duration << "#{mins % 60} #{m}"
    end

    duration.join(' ')
  end
end