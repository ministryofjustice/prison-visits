class RenameHatfield < ActiveRecord::Migration
  def change
    VisitMetricsEntry.where(prison_name: 'Hatfield (moorland Open)').update_all(prison_name: 'Hatfield Open')
  end
end
