class VisitController < ApplicationController
  helper_method :visit

  def visit
    session[:visit]
  end

  def abandon
    reset_session
  end

  def status
    @visit_status = metrics_logger.visit_status(params[:id])
  end

  def metrics_logger
    METRICS_LOGGER
  end
end
