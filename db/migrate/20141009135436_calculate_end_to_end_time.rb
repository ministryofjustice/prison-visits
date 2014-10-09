class CalculateEndToEndTime < ActiveRecord::Migration
  def change
    VisitMetricsEntry.where.not(processed_at: nil).where(end_to_end_time: nil).update_all('end_to_end_time = EXTRACT(epoch FROM processed_at - requested_at)')
    VisitMetricsEntry.where.not(processed_at: nil).where(processing_time: nil).update_all('processing_time = EXTRACT(epoch FROM processed_at - opened_at)')
  end
end
