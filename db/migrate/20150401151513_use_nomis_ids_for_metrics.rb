class UseNomisIdsForMetrics < ActiveRecord::Migration
  def change
    rename_column :visit_metrics_entries, :prison_name, :nomis_id
  end
end
