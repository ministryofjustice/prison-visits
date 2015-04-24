class RagStatusReport
  SECONDS_PER_DAY = 24 * 60 * 60

  def initialize(percentile)
    @percentile = percentile
  end

  def this_period
    this_fortnight = Date.today.cweek / 2
    @this_period ||= query(Date.today.year, this_fortnight, @percentile)
  end

  def query(year, fortnight, percentile)
    @rag_count ||= rag_count(VisitMetricsEntry.find_by_sql([%Q{
WITH ranked_times AS (
  SELECT nomis_id, end_to_end_time, cume_dist() OVER (PARTITION BY nomis_id ORDER BY end_to_end_time)
  FROM visit_metrics_entries
  WHERE EXTRACT(isoyear FROM processed_at) = ?
  AND EXTRACT(week from processed_at) / 2 = ?
)
SELECT nomis_id, min(end_to_end_time) as end_to_end_time from ranked_times
WHERE cume_dist >= ?
GROUP BY nomis_id}, year, fortnight, percentile]))
end

  def rag_count(records)
    records.inject(Hash.new(0)) do |h, record|
      h[RagStatusReport.classify(record.end_to_end_time)] += 1
      h
    end
  end

  def as_json(options={})
    {
      item: [
       {
         value: this_period[:red],
         text: "Over 4 days"
       },
       {
         value: this_period[:amber],
         text: "Between 3 and 4 days"
       },
       {
         value: this_period[:green],
         text: "Less than 3 days"
       }
      ]
    }
  end

  def self.classify(score)
    case score
    when 0..(3 * SECONDS_PER_DAY)
      :green
    when (3 * SECONDS_PER_DAY)..(4 * SECONDS_PER_DAY)
      :amber
    else
      :red
    end
  end
end
