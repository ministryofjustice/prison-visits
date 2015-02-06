class FortnightlyPerformanceReport
  def initialize(model_class, prison_name, year)
    @model = model_class
    @prison_name = prison_name
    @year = year
  end

  def performance
    @model.find_by_sql [%Q{
WITH percentiles AS (
  SELECT requested_at,
  EXTRACT(week FROM requested_at)::integer / 2 AS fortnight,
         end_to_end_time,
         cume_dist() OVER (PARTITION BY EXTRACT(week FROM requested_at)::integer / 2
                           ORDER BY end_to_end_time)
  FROM visit_metrics_entries
  WHERE end_to_end_time IS NOT NULL
  AND prison_name = ? AND EXTRACT(isoyear FROM requested_at) = ?
  ORDER BY fortnight)
SELECT MIN(DATE_TRUNC('week', requested_at))::date AS x, MIN(end_to_end_time) AS y
FROM percentiles
WHERE cume_dist >= 0.95
GROUP BY fortnight
ORDER BY x}, @prison_name, @year]
  end

  def volume
    @model.find_by_sql [%Q{
SELECT MIN(DATE_TRUNC('week', requested_at))::date AS x, COUNT(*) AS y FROM visit_metrics_entries
WHERE prison_name = ? AND EXTRACT(isoyear FROM requested_at) = ?
GROUP BY EXTRACT(week FROM requested_at)::integer / 2
ORDER BY x
}, @prison_name, @year]
  end
end
