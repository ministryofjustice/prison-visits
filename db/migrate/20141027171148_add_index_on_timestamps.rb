class AddIndexOnTimestamps < ActiveRecord::Migration
  def change
    add_index :visit_metrics_entries, [:requested_at, :processed_at]
  end
end
