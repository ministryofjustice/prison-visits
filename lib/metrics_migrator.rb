class MetricsMigrator
  def initialize(elastic_client, model_class)
    @client = elastic_client
    @model = model_class
  end

  def run
    elastic_results['hits']['hits'].each do |entry|
      entry = entry['_source']

      visit_id = entry['visit_id']
      timestamp = Time.at(entry['timestamp']).utc
      prison = entry['prison']

      puts visit_id

      case entry['label0']
      when 'visit_request'
        visit_request(visit_id, timestamp, prison)
      when 'opened_link'
        opened_link(visit_id, timestamp)
      when 'result_rejected'
        result_rejected(visit_id, timestamp, entry['label1'])
      when 'result_confirmed'
        result_confirmed(visit_id, timestamp)
      end
    end
  end

  def elastic_results
    puts 'fetching results...'
    @client.search(index: :pvb, size: 1_000_000, sort: 'timestamp:asc')
  end

  def visit_request(visit_id, timestamp, prison)
    @model.create!(visit_id: visit_id, requested_at: timestamp, prison_name: prison)
  rescue
    puts "duplicate entry: #{visit_id}"
  end

  def opened_link(visit_id, timestamp)
    find_record(visit_id) do |record|
      record.opened_at = timestamp
      record.save!
    end
  end

  def result_rejected(visit_id, timestamp, reason)
    find_record(visit_id) do |record|
      record.processed_at = timestamp
      record.end_to_end_time = record.processed_at - record.requested_at
      record.processing_time = record.processed_at - record.opened_at if record.opened_at
      record.outcome = :rejected
      record.reason = reason
      record.save!
    end
  end

  def result_confirmed(visit_id, timestamp)
    find_record(visit_id) do |record|
      record.processed_at = timestamp
      record.end_to_end_time = record.processed_at - record.requested_at
      record.processing_time = record.processed_at - record.opened_at if record.opened_at
      record.outcome = :confirmed
      record.save!
    end
  end

  def find_record(visit_id)
    if record = @model.where(visit_id: visit_id).first
      yield record
    else
      puts "no corresponding record: #{visit_id}"
    end
  end
end
