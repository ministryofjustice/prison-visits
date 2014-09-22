require 'csv'

class CalculatedMetrics
  attr_reader :total_visits, :waiting_visits, :overdue_visits, :confirmed_visits, :rejected_visits, :rejected_for_reason, :end_to_end_times, :processing_times

  def initialize(model, overdue_threshold)
    @model = model
    @overdue_threshold = overdue_threshold
  end

  def refresh
    @total_visits = @model.group(:prison_name).count
    @waiting_visits = @model.group(:prison_name).where(processed_at: nil).count
    @overdue_visits = @model.group(:prison_name).where("processed_at IS NULL AND ? - requested_at > INTERVAL '? seconds'", Time.now, @overdue_threshold).count
    @confirmed_visits = @model.group(:prison_name).where(outcome: 'confirmed').count
    @rejected_visits = @model.group(:prison_name).where(outcome: 'rejected').count
    @rejected_for_reason = @model.group(:prison_name, :reason).where(outcome: 'rejected').count
    @end_to_end_times = calculate_percentiles('end_to_end_time')
    @processing_times = calculate_percentiles('processing_time')

    [@total_visits, @waiting_visits, @overdue_visits, @confirmed_visits, @rejected_visits, @rejected_for_reason].each do |hash|
      hash.default = 0
    end
    
    self
  end

  def percent_rejected(prison, reason=nil)
    if reason
      1.0 * (@rejected_for_reason[[prison, reason]] || 0) / @total_visits[prison]
    else
      1.0 * (@rejected_visits[prison] || 0) / @total_visits[prison]
    end
  end

  def calculate_percentiles(column)
    @model.connection.execute(%Q{
WITH percentiles AS (SELECT prison_name, #{column}, cume_dist() OVER (PARTITION BY prison_name ORDER BY #{column}) AS percentile
                     FROM visit_metrics_entries WHERE #{column} IS NOT NULL),
     top_percentiles AS (SELECT prison_name, #{column}, rank() OVER (PARTITION BY prison_name ORDER BY #{column})
                     FROM percentiles WHERE percentile >= 0.95)
SELECT prison_name, #{column} FROM top_percentiles WHERE rank = 1
}).each_with_object({}) do |row, h|
      h[row['prison_name']] = row[column].to_i
    end
  end
end

