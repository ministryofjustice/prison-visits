class HeartbeatController < ApplicationController
  def pingdom
    @now = Time.now
    @max_record_id = VisitMetricsEntry.maximum(:id)
    @last_visit_id = VisitMetricsEntry.find(@max_record_id).visit_id
    @later = Time.now
  end

  def healthcheck
    render json: {
      checks: {
        sendgrid: true,
        messagelabs: true,
        database: true
      }
    }
  end
end
