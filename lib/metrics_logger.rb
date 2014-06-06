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
    @client.search(index: INDEX_NAME,
                   search_type: :count,
                   body: {
                     query: {
                       bool: {
                         must: [{term: { visit_id: visit.visit_id }}, {prefix: { label0: "result_"}}]
                       }
                     }
                   })['hits']['total'] > 0
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
