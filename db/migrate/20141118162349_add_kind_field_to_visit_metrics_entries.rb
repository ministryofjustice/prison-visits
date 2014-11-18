class AddKindFieldToVisitMetricsEntries < ActiveRecord::Migration
  def change
    add_column :visit_metrics_entries, :kind, :string
    VisitMetricsEntry.where(kind: nil).update_all(kind: 'deferred')
  end
end
