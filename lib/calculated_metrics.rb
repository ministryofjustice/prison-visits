require 'csv'

class CalculatedMetrics
  attr_reader :total_visits, :waiting_visits, :overdue_visits,
    :confirmed_visits, :rejected_visits, :rejected_for_reason,
    :end_to_end_median_times, :end_to_end_times, :processing_times

  def initialize(model, overdue_threshold, date_range=nil)
    @model = model
    @overdue_threshold = overdue_threshold
    @date_range = date_range

    refresh
  end

  def scope
    if @date_range
      @model.
        where('requested_at IS NULL OR requested_at > ?', @date_range.first).
        where('processed_at IS NULL OR processed_at <= ?', @date_range.last)
    else
      @model
    end
  end

  def refresh
    @total_visits = scope.group(:nomis_id).count
    @waiting_visits = scope.group(:nomis_id).where(processed_at: nil).count
    @overdue_visits = scope.group(:nomis_id).
      where(
        "processed_at IS NULL AND ? - requested_at > INTERVAL '? seconds'",
        Time.now, @overdue_threshold).count
    @confirmed_visits = scope.group(:nomis_id).where(outcome: 'confirmed').
      count
    @rejected_visits = scope.group(:nomis_id).where(outcome: 'rejected').count
    @rejected_for_reason = scope.group(:nomis_id, :reason).
      where(outcome: 'rejected').count
    @end_to_end_median_times = calculate_percentiles('end_to_end_time', 0.5)
    @end_to_end_times = calculate_percentiles('end_to_end_time', 0.95)
    @processing_times = calculate_percentiles('processing_time', 0.95)

    [
      @total_visits, @waiting_visits, @overdue_visits, @confirmed_visits,
      @rejected_visits, @rejected_for_reason
    ].each do |hash|
      hash.default = 0
    end

    self
  end

  def percent_rejected(prison, reason=nil)
    if reason
      1.0 * (@rejected_for_reason[[prison, reason]] || 0) /
        @total_visits[prison]
    else
      1.0 * (@rejected_visits[prison] || 0) / @total_visits[prison]
    end
  end

  private
  def calculate_percentiles(column, percentile)
    # This is a truly horrible hack. It lets us get past AR built-in value
    # quoting, by pretending to be another object. It is needed so that we
    # can parametrize two queries below by column, without resorting to
    # putting the query together by hand. Don't call this method from outside
    # this class, please.
    column.define_singleton_method(:quoted_id) do
      column
    end
    if @date_range
      calculate_percentiles_with_date_range(column, percentile)
    else
      calculate_percentiles_without_date_range(column, percentile)
    end.each_with_object({}) do |row, h|
      h[row['nomis_id']] = row[column].to_i
    end
  end

  def calculate_percentiles_with_date_range(column, percentile)
    query = <<-SQL
      WITH percentiles AS (SELECT nomis_id, ?, cume_dist()
                            OVER (PARTITION BY nomis_id ORDER BY ?
                          ) AS percentile
                           FROM visit_metrics_entries WHERE ? IS NOT NULL
                           AND requested_at > ?::date
                           AND processed_at <= ?::date),
           top_percentiles AS (SELECT nomis_id, ?, rank()
                                OVER (PARTITION BY nomis_id ORDER BY ?)
                           FROM percentiles WHERE percentile >= ?)
      SELECT nomis_id, ? FROM top_percentiles WHERE rank = 1
    SQL

    @model.find_by_sql [query, column, column, column,
                        @date_range.first,
                        @date_range.last, column, column, percentile, column]
  end

  def calculate_percentiles_without_date_range(column, percentile)
    query = <<-SQL
      WITH percentiles AS (SELECT nomis_id, ?, cume_dist()
                            OVER (PARTITION BY nomis_id ORDER BY ?
                          ) AS percentile
                           FROM visit_metrics_entries WHERE ? IS NOT NULL),
           top_percentiles AS (SELECT nomis_id, ?, rank()
                                OVER (PARTITION BY nomis_id ORDER BY ?)
                           FROM percentiles WHERE percentile >= ?)
      SELECT nomis_id, ? FROM top_percentiles WHERE rank = 1
    SQL

    @model.find_by_sql [query, column, column, column, column,
                        column, percentile, column]
  end
end
