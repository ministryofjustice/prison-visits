class MakeMetricsConsistent < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE visit_metrics_entries
      SET outcome = 'pending'
      WHERE outcome IS NULL
    SQL

    change_column_null :visit_metrics_entries, :outcome, false, 'pending'

    execute <<-SQL
      UPDATE visit_metrics_entries
      SET kind = 'deferred'
      WHERE kind IS NULL
    SQL

    change_column_null :visit_metrics_entries, :kind, false, 'deferred'
  end
end
