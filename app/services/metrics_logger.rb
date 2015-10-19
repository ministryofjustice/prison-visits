class MetricsLogger
  def record_visit_request(visit)
    nomis_id = visit.prison_nomis_id
    VisitMetricsEntry.create!(
      visit_id: visit.visit_id,
      requested_at: now_in_utc,
      kind: 'deferred',
      nomis_id: nomis_id,
      outcome: 'pending'
    )
  rescue PG::ConnectionBad => e
    Raven.capture_exception(e)
  end

  def record_link_click(visit)
    update_entry(visit.visit_id) do |e|
      e.kind = 'deferred'
      e.opened_at ||= now_in_utc
    end
  end

  def record_booking_confirmation(visit)
    update_entry(visit.visit_id) do |e|
      e.processed_at = now_in_utc
      e.outcome = 'confirmed'
      e.processing_time = e.processed_at - e.opened_at
      e.end_to_end_time = e.processed_at - e.requested_at
    end
  end

  def record_booking_rejection(visit, reason)
    update_entry(visit.visit_id) do |e|
      e.processed_at = now_in_utc
      e.outcome = 'rejected'
      e.reason = reason
      e.processing_time = e.processed_at - e.opened_at
      e.end_to_end_time = e.processed_at - e.requested_at
    end
  end

  def record_booking_cancellation(visit_id, type)
    update_entry(visit_id) do |e|
      e.outcome = type
    end
  end

  def processed?(visit)
    entry = find_entry(visit.visit_id)
    if entry
      entry.processed_at.present?
    else
      false
    end
  rescue PG::ConnectionBad => e
    Raven.capture_exception(e)
    'unknown'
  end

  def request_cancelled?(visit)
    'request_cancelled' == visit_status(visit.visit_id)
  end

  def visit_status(visit_id)
    entry = find_entry(visit_id)
    if entry
      entry.outcome || 'pending'
    else
      'unknown'
    end
  rescue PG::ConnectionBad => e
    Raven.capture_exception(e)
    'unknown'
  end

  def now_in_utc
    Time.now.utc
  end

  def update_entry(visit_id)
    entry = find_entry(visit_id)
    if entry
      yield entry
      entry.save! if entry.changed?
    end
  rescue PG::ConnectionBad => e
    Raven.capture_exception(e)
  end

  def find_entry(visit_id)
    VisitMetricsEntry.where(visit_id: visit_id).first
  end
end
