class DetailedMetrics
  THREE_DAYS = 3 * 24 * 3600

  def initialize(model, prison_name)
    @scoped_model = model.for_prison(prison_name)
  end

  def processed_before(interval=THREE_DAYS)
    @scoped_model.processed.where('end_to_end_time < ?', interval).count
  end

  def processed_after(interval=THREE_DAYS)
    @scoped_model.processed.where('end_to_end_time >= ?', interval).count
  end

  def time_since_last_unprocessed
    @scoped_model.waiting.minimum('EXTRACT(EPOCH FROM NOW() - requested_at)').to_i
  end
  
  def performance_score
    score = 1.0 * processed_before / (processed_before + processed_after)
  end

  def performance_score_label
    case performance_score
    when (0.97..1)
      'Exemplary'
    when (0.95..0.97)
      'Very Good'
    when (0.93..0.95)
      'Good'
    when (0.92..0.93)
      'Acceptable'
    when (0.9..0.92)
      'Poor'
    when (0.8..0.9)
      'Very Poor'
    when (0..0.8)
      'Unacceptable'
    end
  end

  def week_hour_breakdown(column)
    @scoped_model.
      group("EXTRACT(dow FROM #{column})::integer").
      group("EXTRACT(hour FROM #{column})::integer").
      processed.
      count.
      inject(Array.new(7) { Array.new(24, 0) }) do |a, ((dow, hour), count)|
      a[dow][hour] = count
      a
    end
  end

  def end_to_end_times
    series('end_to_end_time')
  end

  def processing_times
    series('processing_time')
  end

  def waiting_times
    @scoped_model.waiting.pluck("EXTRACT(epoch FROM NOW() - requested_at) AS delay")
  end

  def total
    @scoped_model.count
  end

  def waiting
    @scoped_model.waiting.count
  end

  def series(column)
    @scoped_model.where.not(column => nil).pluck(column)
  end

  def median(array)
    size = array.size
    array.sort[size / 2 + 1]
  end
end
