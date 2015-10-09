class FortnightlyPerformanceReport
  def initialize(model_class, nomis_id, year)
    @model = model_class
    @nomis_id = nomis_id
    @year = year
  end

  def performance(percentile)
    @model.find_by_sql ["
WITH percentiles AS (
  SELECT requested_at,
  EXTRACT(week FROM requested_at)::integer / 2 AS fortnight,
         end_to_end_time,
         cume_dist() OVER (PARTITION BY EXTRACT(week
                                                  FROM requested_at
                                                )::integer / 2
                           ORDER BY end_to_end_time)
  FROM visit_metrics_entries
  WHERE end_to_end_time IS NOT NULL
  AND nomis_id = ? AND EXTRACT(isoyear FROM requested_at) = ?
  ORDER BY fortnight)
SELECT MIN(DATE_TRUNC('week', requested_at))::date AS x,
       MIN(end_to_end_time) AS y
FROM percentiles
WHERE cume_dist >= ?
GROUP BY fortnight
ORDER BY x", @nomis_id, @year, percentile]
  end

  def volume
    @model.find_by_sql ["
SELECT MIN(DATE_TRUNC('week', requested_at))::date AS x, COUNT(*) AS y
FROM visit_metrics_entries
WHERE nomis_id = ? AND EXTRACT(isoyear FROM requested_at) = ?
GROUP BY EXTRACT(week FROM requested_at)::integer / 2
ORDER BY x
", @nomis_id, @year]
  end
end
