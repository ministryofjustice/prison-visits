require 'csv'

class WeeklyConfirmationsReport
  def initialize(model, year, start_of_year)
    @model = model
    @year = year
    @start_of_year = start_of_year
  end

  def week_range
    @min_week..@max_week
  end

  def for_prison(prison_name)
    @dataset[prison_name]
  end

  def refresh
    @min_week = 55
    @max_week = 0
    hash_with_default = Hash.new { |h, k|
      h[k] = Array.new(52, 0)
    }

    @dataset = @model.connection.execute("
SELECT prison_name,
       EXTRACT(week FROM processed_at) AS weekno,
       COUNT(*)
FROM visit_metrics_entries
WHERE processed_at IS NOT NULL AND EXTRACT(year FROM processed_at) = 2014
GROUP BY prison_name, EXTRACT(week FROM processed_at) ORDER BY prison_name, weekno").inject(hash_with_default) do |h, row|

      weekno = row['weekno'].to_i
      prison_name = row['prison_name']
      count = row['count'].to_i

      @min_week = weekno if weekno < @min_week
      @max_week = weekno if weekno > @max_week

      h[prison_name][weekno] = count
      h
    end

    self
  end

  def csv
    CSV.generate(headers: true) do |csv|
      csv << ['Prison'] + week_range.map { |weekno| @start_of_year + weekno * 7 }
      @dataset.keys.sort.each do |prison|
        csv << [prison] + week_range.map { |weekno| @dataset[prison][weekno] }
      end
    end
  end
end
