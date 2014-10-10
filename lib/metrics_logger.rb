class MetricsLogger
  def record_visit_request(visit)
    VisitMetricsEntry.create!(visit_id: visit.visit_id, requested_at: now_in_utc, prison_name: visit.prisoner.prison_name)
  rescue PG::ConnectionBad => e
    Raven.capture_exception(e)
  end

  def record_link_click(visit)
    update_entry(visit.visit_id) do |e|
      e.opened_at ||= now_in_utc
    end
  end

  def record_booking_confirmation(visit)
    update_entry(visit.visit_id) do |e|
      e.processed_at = now_in_utc
      e.outcome = :confirmed
    end
  end

  def record_booking_rejection(visit, reason)
    update_entry(visit.visit_id) do |e|
      e.processed_at = now_in_utc
      e.outcome = :rejected
      e.reason = reason
    end
  end

  def processed?(visit)
    [:confirmed, :rejected].include?(visit_status(visit.visit_id))
  end

  def visit_status(visit_id)
    if entry = find_entry(visit_id)
      (entry.outcome || :pending).to_sym
    else
      :unknown
    end
  rescue PG::ConnectionBad => e
    Raven.capture_exception(e)
    :unknown
  end

  def now_in_utc
    Time.now.utc
  end

  def update_entry(visit_id)
    if entry = find_entry(visit_id)
      yield entry
      puts entry.changes
      entry.save! if entry.changed?
    end
  rescue PG::ConnectionBad => e
    Raven.capture_exception(e)
  end

  def find_entry(visit_id)
    VisitMetricsEntry.where(visit_id: visit_id).first
  end
end
