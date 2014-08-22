require 'csv'

class CalculatedMetrics
  class DataSeries < Array
    def percentile(n=95)
      return nil if self.size < 16

      percentile_idx = (self.size * n / 100.0).round

      self[percentile_idx]
    end

    def self.from_array(array)
      new(array.sort)
    end
  end

  def initialize
    @waiting_visit_ids = {}
    @opened_visit_ids = {}
    @end_to_end_times = []
    @processing_times = []
    @total_visits = 0
    @waiting_visits = 0
    @rejected_visits = 0
    @confirmed_visits = 0
    @rejected_for_reason = Hash.new(0)
  end

  def update(elastic_feed)
    return self if elastic_feed.empty?

    elastic_feed['hits']['hits'].each do |entry|
      entry = entry['_source']
      visit_id = entry['visit_id']
      timestamp = entry['timestamp']

      case entry['label0']
      when 'visit_request'
        @total_visits +=1
        @waiting_visit_ids[visit_id] = timestamp
      when 'opened_link'
        @opened_visit_ids[visit_id] = timestamp
      when 'result_rejected'
        if start_time = @waiting_visit_ids[visit_id]
          @end_to_end_times << timestamp - start_time
        end
        if opened_time = @opened_visit_ids[visit_id]
          @processing_times << timestamp - opened_time
        end

        @waiting_visit_ids.delete(visit_id)
        @opened_visit_ids.delete(visit_id)
        @rejected_visits += 1
        @rejected_for_reason[entry['label1']] += 1
      when 'result_confirmed'
        if start_time = @waiting_visit_ids[visit_id]
          @end_to_end_times << timestamp - start_time
        end
        if opened_time = @opened_visit_ids[visit_id]
          @processing_times << timestamp - opened_time
        end

        @waiting_visit_ids.delete(visit_id)
        @opened_visit_ids.delete(visit_id)
        @confirmed_visits += 1
      end
    end
    self
  end

  def as_csv_row(prison_name, timestamp)
    [
     prison_name,
     total_visits,
     waiting_visits,
     overdue_visits(timestamp),
     rejected_visits,
     confirmed_visits,
     end_to_end_time.percentile(95),
     processing_time.percentile(95),
     percent_rejected
    ]
  end

  def total_visits
    @total_visits
  end

  def waiting_visits
    @waiting_visit_ids.size
  end

  def overdue_visits(now)
    now = now.to_i
    @waiting_visit_ids.count do |_, timestamp|
      timestamp < now
    end
  end

  def rejected_visits
    @rejected_visits
  end

  def confirmed_visits
    @confirmed_visits
  end

  def rejected_for_reason
    @rejected_for_reason
  end

  def end_to_end_time
    DataSeries.from_array(@end_to_end_times)
  end

  def processing_time
    DataSeries.from_array(@processing_times)
  end

  def percent_rejected(reason=nil)
    (reason ? @rejected_for_reason[reason] : @rejected_visits) / @total_visits.to_f
  end
end
