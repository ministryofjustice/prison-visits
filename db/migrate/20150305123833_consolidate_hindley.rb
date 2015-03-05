class ConsolidateHindley < ActiveRecord::Migration
  def change
    VisitMetricsEntry.transaction do
      VisitMetricsEntry.connection.execute("LOCK TABLE visit_metrics_entries")
      VisitMetricsEntry.where(prison_name: 'Hindley (Young Adult 18-21 only)').update_all(prison_name: 'Hindley')
      VisitMetricsEntry.where(prison_name: 'Hindley (Young People 15-18 only)').update_all(prison_name: 'Hindley')
    end
  end
end
