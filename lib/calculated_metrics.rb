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

  def initialize(aggregated_metrics)
    @dataset = aggregated_metrics
    @percent_rejected = {}
  end

  def csv
    CSV.generate do |csv|
      csv << ['Prison', 'Total', 'Waiting', 'Overdue', 'Rejected', 'Confirmed', 'End-to-end time', 'Processing time', '% rejected']
      prisons.each do |prison|
        csv << [prison,
                total_visits[prison],
                waiting_visits[prison],
                overdue_visits((Time.now - 3.days).to_i)[prison],
                rejected_visits[prison],
                confirmed_visits[prison],
                end_to_end_time[prison].percentile(95),
                processing_time[prison].percentile(95),
                percent_rejected[prison]
               ]
      end
    end
  end

  def prisons
    @prisons ||= @dataset.keys.sort
  end

  def total_visits
    @total_visits ||= @dataset.inject({}) do |h, (prison, visits)|
      h[prison] = visits.size
      h
    end
  end

  def waiting_visits
    @waiting_visits ||= @dataset.inject(Hash.new(0)) do |h, (prison, visits)|
      h[prison] += visits.count do |visit_id, events|
        !has_been_processed?(events)
      end
      h
    end
  end

  def overdue_visits(timestamp)
    @overdue_visits ||= @dataset.inject(Hash.new(0)) do |h, (prison, visits)|
      h[prison] += visits.count do |visit_id, events|
        if !has_been_processed?(events)
          has_overdue_request?(events, timestamp)
        end
      end
      h
    end
  end

  def rejected_visits
    @rejected_visits ||= @dataset.inject(Hash.new(0)) do |h, (prison, visits)|
      h[prison] += visits.count do |visit_id, events|
        has_been_rejected?(events)
      end
      h
    end
  end

  def confirmed_visits
    @confirmed_visits ||= @dataset.inject(Hash.new(0)) do |h, (prison, visits)|
      h[prison] += visits.count do |visit_id, events|
        has_been_confirmed?(events)
      end
      h
    end
  end

  def end_to_end_time
    @end_to_end_time ||= @dataset.inject({}) do |h, (prison, visits)|
      completed_visits = visits.values.select do |events|
        events.find do |event|
          event['label0'] =~ /^result_/
        end
      end

      h[prison] = DataSeries.from_array(completed_visits.map do |events|
        start = has_been_requested?(events) || next

        finish = has_been_processed?(events) || next

        finish['timestamp'] - start['timestamp']
      end.reject do |value|
        value.nil?
      end)
      h
    end
  end

  def processing_time
    @processing_time ||= @dataset.inject({}) do |h, (prison, visits)|
      completed_visits = visits.values.select do |events|
        has_been_processed?(events)
      end

      h[prison] = DataSeries.from_array(completed_visits.map do |events|
        start = has_been_opened?(events)
        finish = has_been_processed?(events)

        finish['timestamp'] - start['timestamp']
      end)
      h
    end
  end

  def percent_rejected(reason=nil)
    @percent_rejected[reason] ||=
      @dataset.inject({}) do |h, (prison, visits)|
      rejected = completed = 0
      
      visits.each do |visit, events|
        if has_been_processed?(events)
          completed += 1
        end
        
        if event = has_been_rejected?(events)
          if reason
            if event['label1'] == reason
              rejected += 1
            end
          else
            rejected += 1
          end
        end
      end

      h[prison] = 1.0 * rejected / completed
      h
    end
  end

  def self.from_elasticsearch(raw_metrics)
    new(aggregate(raw_metrics))
  end

  def self.aggregate(raw_metrics)
    return {} if raw_metrics.empty?

    aggregated = raw_metrics['hits']['hits'].inject({}) do |h, row|
      entry = row['_source']
      visit_id = entry.delete('visit_id')
      prison = entry.delete('prison')

      h[prison] ||= {}
      h[prison][visit_id] ||= []
      h[prison][visit_id] << entry
      h
    end

    aggregated.each_pair do |prison, visits|
      visits.each_pair do |visit_id, entries|
        entries.sort_by! do |entry|
          entry['timestamp']
        end
      end
    end

    aggregated
  end

  private
  def has_been_processed?(events)
    events.find do |event|
      event['label0'] =~ /^result_/
    end
  end

  def has_been_opened?(events) 
    events.find do |event|
      event['label0'] == 'opened_link'
    end
  end

  def has_been_requested?(events)
    events.find do |event|
      event['label0'] == 'visit_request'
    end
  end

  def has_overdue_request?(events, timestamp)
    events.find do |event|
      event['label0'] == 'visit_request' && event['timestamp'] < timestamp
    end
  end

  def has_been_rejected?(events)
    events.find do |event|
      event['label0'] == 'result_rejected'
    end
  end

  def has_been_confirmed?(events)
    events.find do |event|
      event['label0'] == 'result_confirmed'
    end
  end
end
