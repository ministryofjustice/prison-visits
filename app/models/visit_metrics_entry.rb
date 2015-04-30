class VisitMetricsEntry < ActiveRecord::Base
  validates_presence_of :visit_id, :nomis_id, :requested_at
  validates_inclusion_of :kind, in: %w{deferred instant}
  validates_inclusion_of :outcome, in: %w{pending confirmed rejected request_cancelled visit_cancelled}
  validates_length_of :nomis_id, is: 3

  scope :processed, -> { where.not(processed_at: nil) }
  scope :waiting, -> { where(processed_at: nil) }
  scope :for_nomis_id, -> (p) { where(nomis_id: p) }
  scope :after, -> (date) { where('requested_at > ?', date) }
  scope :before, -> (date) { where('processed_at <= ?', date) }
  scope :deferred, -> { where(kind: :deferred) }
  scope :instant, -> { where(kind: :instant) }
  scope :confirmed, -> { where(outcome: 'confirmed') }

  def processed?
    if block_given?
      yield if outcome
    else
      outcome
    end
  end

  def rejected?
    yield if outcome == 'rejected'
  end

  def confirmed?
    yield if outcome == 'confirmed'
  end
end
