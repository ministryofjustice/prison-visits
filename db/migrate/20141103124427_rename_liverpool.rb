class RenameLiverpool < ActiveRecord::Migration
  def change
    VisitMetricsEntry.where(prison_name: 'Liverpool (Open only)').update_all(prison_name: 'Liverpool Social Visits')
  end
end
