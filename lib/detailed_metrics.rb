class DetailedMetrics
  include ActiveRecord::ConnectionAdapters::Quoting

  THREE_DAYS = 3 * 24 * 3600

  def initialize(model, nomis_id)
    @scoped_model = model.for_nomis_id(nomis_id)
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
  
  def week_hour_breakdown(column)
    column.define_singleton_method(:quoted_id) do
      column
    end

    @scoped_model.
      group("EXTRACT(dow FROM #{quote(column)})::integer").
      group("EXTRACT(hour FROM #{quote(column)})::integer").
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

  def percentile(array, pct=0.95)
    size = array.size
    array.sort[(pct * size).floor]
  end
end
