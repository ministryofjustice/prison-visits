class RenameHollesleyBay < ActiveRecord::Migration
  def change
    VisitMetricsEntry.where(prison_name: 'Hollesley Bay').update_all(prison_name: 'Hollesley Bay Open')
  end
end
