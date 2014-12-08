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

  def update_status
    @visit_status = metrics_logger.visit_status(params[:id])

    if params[:cancel]
      metrics_logger.record_booking_cancellation(params[:id], "#{params[:cancel]}_cancelled")
    else
      flash[:notice] = "You need to confirm that you want to cancel this visit."
    end

    redirect_to visit_status_path(id: params[:id])
  end

  def metrics_logger
    METRICS_LOGGER
  end
end
