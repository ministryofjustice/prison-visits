class CreateVisitMetricsEntries < ActiveRecord::Migration
  def change
    create_table :visit_metrics_entries do |t|
      t.string :visit_id
      t.string :prison_name
      t.timestamp :requested_at
      t.timestamp :opened_at
      t.timestamp :processed_at
      t.string :outcome
      t.string :reason
    end

    add_index :visit_metrics_entries, [:visit_id], unique: true
    add_index :visit_metrics_entries, [:prison_name]
    add_index :visit_metrics_entries, [:requested_at]
  end
end
