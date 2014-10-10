class CalculateProcessingTime < ActiveRecord::Migration
  def change
    VisitMetricsEntry.where.not(processed_at: nil).where('processing_time < 0').update_all('processing_time = NULL')
  end
end
