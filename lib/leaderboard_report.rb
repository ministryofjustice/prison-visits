class LeaderboardReport
  # How does this fortnight's performance compare to last fortnight's?

  def initialize(percentile, prison_labeling_function)
    @percentile = percentile
    @prison_labeling_function = prison_labeling_function.bind(self)
  end

  def this_period
    this_fortnight = Date.today.cweek / 2
    @this_period ||= query(Date.today.year, this_fortnight, @percentile)
  end

  def prev_period
    prev_fortnight = Date.today.cweek / 2 - 1
    @prev_period ||= query(Date.today.year, prev_fortnight, @percentile)
  end
  
  def query(year, fortnight, percentile)
    VisitMetricsEntry.find_by_sql([%Q{
WITH ranked_times AS (
  SELECT nomis_id, end_to_end_time, cume_dist() OVER (PARTITION BY nomis_id ORDER BY end_to_end_time)
  FROM visit_metrics_entries
  WHERE EXTRACT(isoyear FROM processed_at) = ?
  AND EXTRACT(week from processed_at) / 2 = ?
)
SELECT nomis_id, min(end_to_end_time) as end_to_end_time, rank() OVER (ORDER BY min(end_to_end_time)) as rank
FROM ranked_times
WHERE cume_dist >= ?
GROUP BY nomis_id
}, year, fortnight, percentile]).inject({}) do |h, row|
      h.merge(row.nomis_id => row)
    end
  end

  def ranked_performance
    this_period.inject([]) do |a, (nomis_id, row)|
      record = {
        label: @prison_labeling_function.call(nomis_id),
        value: row.end_to_end_time / (3600.0 * 24),
      }
      if rank = prev_period[nomis_id].try(:rank)
        record[:previous_rank] = rank
      end
      a << record
    end
  end

  def top(n)
    JSONPresenter.new(ranked_performance.first(n))
  end

  def bottom(n)
    JSONPresenter.new(ranked_performance.last(n).reverse)
  end

  class JSONPresenter
    def initialize(results)
      @results = results
    end

    def as_json(options={})
      {
        items: @results
      }
    end
  end
end
