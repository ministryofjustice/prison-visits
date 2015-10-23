class AddKindFieldToVisitMetricsEntries < ActiveRecord::Migration
  def change
    add_column :visit_metrics_entries, :kind, :string, default: 'deferred'
  end
end
