require 'csv'

class WeeklyConfirmationsReport
  attr_reader :total

  def initialize(model, year, start_of_year, prison_labeling_function)
    @model = model
    @year = year
    @start_of_year = start_of_year
    @prison_labeling_function = prison_labeling_function.bind(self)
  end

  def week_range
    @min_week..@max_week
  end

  def for_nomis_id(nomis_id)
    @dataset[nomis_id]
  end

  def refresh
    @min_week = 55
    @max_week = 0
    hash_with_default = Hash.new { |h, k|
      h[k] = Array.new(52, 0)
    }

    @dataset = @model.find_by_sql(["
SELECT nomis_id,
       EXTRACT(week FROM processed_at) AS weekno,
       COUNT(*)
FROM visit_metrics_entries
WHERE processed_at IS NOT NULL AND EXTRACT(isoyear FROM processed_at) = ?
AND outcome = 'confirmed'
GROUP BY nomis_id, EXTRACT(week FROM processed_at) ORDER BY nomis_id, weekno", @year])
    .inject(hash_with_default) do |h, row|

      weekno = row['weekno'].to_i
      nomis_id = row['nomis_id']
      count = row['count'].to_i

      @min_week = weekno if weekno < @min_week
      @max_week = weekno if weekno > @max_week

      h[nomis_id][weekno] = count
      h
    end

    @total = @model.find_by_sql(["
SELECT EXTRACT(week FROM processed_at) AS weekno, COUNT(*)
FROM visit_metrics_entries
WHERE processed_at IS NOT NULL AND EXTRACT(isoyear FROM processed_at) = ?
AND outcome = 'confirmed'
GROUP BY weekno ORDER BY weekno", @year]).inject(Array.new(52, 0)) do |arr, row|
      arr[row['weekno'].to_i] = row['count'].to_i
      arr
    end

    self
  end

  def csv
    CSV.generate(headers: true) do |csv|
      csv << ['Prison'] + week_range.map { |weekno| @start_of_year + weekno * 7 } + ['NOMIS ID']
      @dataset.keys.sort.each do |prison|
        csv << [@prison_labeling_function.call(prison)] + week_range.map { |weekno| @dataset[prison][weekno] } + [prison]
      end
    end
  end
end
