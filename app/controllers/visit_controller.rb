class VisitController < ApplicationController

  def abandon
    reset_session
  end

  def status
    @visit_status = metrics_logger.visit_status(params[:id])
    if params[:state]
      encryptor.decrypt_and_verify(params[:state])
      @state = params[:state]
    else
      STATSD_CLIENT.increment('pvb.app.status_with_no_state')
    end
  end

  def update_status
    @visit_status = metrics_logger.visit_status(params[:id])
    @visit = encryptor.decrypt_and_verify(params[:state])
    cancel_params
    redirect_to visit_status_path(id: params[:id], state: params[:state])
  end

  private

  def cancel_params
    if params[:cancel]
      if @visit_status == 'pending'
        metrics_logger_record_booking_cancellation(params[:id], 'request')
      else
        PrisonMailer.booking_cancellation_receipt_email(@visit).deliver_later
        metrics_logger_record_booking_cancellation(params[:id], 'visit')
      end
    else
      set_notice :update
    end
  end

  def metrics_logger_record_booking_cancellation(id, status = '')
    metrics_logger.record_booking_cancellation(id, "#{status}_cancelled")
  end
end
