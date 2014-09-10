class PrecalculateProcessingTime < ActiveRecord::Migration
  def change
    add_column :visit_metrics_entries, :processing_time, :integer
    add_column :visit_metrics_entries, :end_to_end_time, :integer
  end
end
