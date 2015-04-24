class UseNomisIdsForMetrics < ActiveRecord::Migration
  def change
    Rails.configuration.prison_data.each_pair do |prison_name, data|
      say_with_time "Renaming #{prison_name} to #{data['nomis_id']}" do
        VisitMetricsEntry.where(prison_name: prison_name).update_all(prison_name: data['nomis_id'])
      end
    end
    rename_column :visit_metrics_entries, :prison_name, :nomis_id
  end
end
