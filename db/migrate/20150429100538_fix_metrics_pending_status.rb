class FixMetricsPendingStatus < ActiveRecord::Migration
  def change
    VisitMetricsEntry.where(outcome: nil).update_all(outcome: :pending)
  end
end
