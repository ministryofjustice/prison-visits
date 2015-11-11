class FixMetricsPendingStatus < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE visit_metrics_entries
      SET outcome = 'pending'
      WHERE outcome IS NULL
    SQL
  end
end
