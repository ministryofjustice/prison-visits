class LeaderboardReport
  # How does this fortnight's performance compare to last fortnight's?

  def initialize(order, percentile)
    @order = order
    @percentile = percentile
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
  SELECT prison_name, end_to_end_time, cume_dist() OVER (PARTITION BY prison_name ORDER BY end_to_end_time)
  FROM visit_metrics_entries
  WHERE EXTRACT(isoyear FROM processed_at) = ?
  AND EXTRACT(week from processed_at) / 2 = ?
)
SELECT prison_name, min(end_to_end_time) as end_to_end_time, rank() OVER (ORDER BY min(end_to_end_time)) as rank
FROM ranked_times
WHERE cume_dist >= ?
GROUP BY prison_name
}, year, fortnight, percentile]).inject({}) do |h, row|
      h.merge(row.prison_name => row)
    end
  end

  def ranked_performance
    this_period.inject([]) do |a, (prison_name, row)|
      a << {
        label: prison_name,
        value: row.end_to_end_time / (3600.0 * 24),
        previous_rank: prev_period[prison_name].rank
      }
    end
  end

  def top(n)
    ranked_performance.first(n)
  end

  def bottom(n)
    ranked_performance.last(n)
  end

  def as_json(options={})
    {
      items: (@order == :top) ? top(10) : bottom(10)
    }
  end
end
