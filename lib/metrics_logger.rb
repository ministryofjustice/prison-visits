class MetricsLogger
  attr_reader :file

  INDEX_NAME = :pvb
  DOCUMENT_TYPE = :metric

  def initialize(client)
    @client = client
  end

  def record_visit_request(visit)
    self << generate_entry(visit, :visit_request)
  end

  def record_link_click(visit)
    self << generate_entry(visit, :opened_link)
  end

  def record_booking_confirmation(visit)
    self << generate_entry(visit, :result_confirmed)
  end

  def record_booking_rejection(visit, reason)
    self << generate_entry(visit, :result_rejected, reason)
  end

  def <<(entry)
    @client.index(entry.merge({index: INDEX_NAME, type: DOCUMENT_TYPE}))
  end

  def processed?(visit)
    [:confirmed, :rejected].include?(visit_status(visit.visit_id))
  end

  def visit_status(visit_id)
    results = @client.search(index: INDEX_NAME, q: "visit_id:#{visit_id}")
    return false unless results['hits']['total'] > 0

    confirmed = results['hits']['hits'].find do |entry|
      entry['_source']['label0'] == 'result_confirmed'
    end

    rejected = results['hits']['hits'].find do |entry|
      entry['_source']['label0'] == 'result_rejected'
    end

    if confirmed
      :confirmed
    elsif rejected
      :rejected
    else
      :pending
    end
  end

  def now_in_utc
    Time.now.utc.to_i
  end

  def generate_entry(visit, *args)
    labels = args.each_with_index.inject({}) do |h, (label, i)|
      h[:"label#{i}"] = label; h
    end
    {
      body: 
      {
        visit_id: visit.visit_id,
        timestamp: now_in_utc,
        prison: visit.prisoner.prison_name,
      }.merge(labels)
    }
  end
end
