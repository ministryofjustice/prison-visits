require 'csv'

class WeeklyConfirmationsReport
  FIRST_WEEK = Date.new(2014, 6, 9)

  def initialize(aggregated)
    @aggregated = aggregated
    @max_timestamp = 0
  end

  def weekly
    @weekly ||= @aggregated.inject({}) do |h, (prison, timestamps)|
      @max_timestamp = [timestamps.max, @max_timestamp].max

      h[prison] = timestamps.group_by do |timestamp|
        (Time.at(timestamp) - FIRST_WEEK.to_time).floor / (7 * 24 * 3600)
      end
      h
    end
  end

  def prisons
    weekly.keys.sort
  end

  def wc_dates
    (FIRST_WEEK..Time.at(@max_timestamp).to_date).step(7).to_a
  end

  def wc_offsets
    wc_dates.size
  end

  def csv
    CSV.generate do |csv|
      csv << ['Prison'] + wc_dates
      prisons.each do |prison|
        csv << [prison] + wc_offsets.times.map { |o| (weekly[prison][o] || []).size }
      end
    end
  end

  def self.from_elasticsearch(raw_metrics)
    return {} if raw_metrics.empty?

    aggregated = raw_metrics['hits']['hits'].inject({}) do |h, row|
      entry = row['_source']
      prison = entry['prison']

      h[prison] ||= []
      h[prison] << entry['timestamp']
      h
    end
    new(aggregated)
  end
end
