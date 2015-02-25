class Deferred::VisitsController < ApplicationController
  include CookieGuard
  include SessionGuard
  before_filter :logstasher_add_visit_id_from_session, only: :update

  def update
    @token = encryptor.encrypt_and_sign(visit)
    PrisonMailer.booking_request_email(visit, @token).deliver
    VisitorMailer.booking_receipt_email(visit, @token).deliver

    metrics_logger.record_visit_request(visit)
    redirect_to deferred_show_visit_path(state: @token)
    reset_session
  end

  def show
    session[:visit] = encryptor.decrypt_and_verify(params[:state])
    logstasher_add_visit_id(visit.visit_id)
    render
    reset_session
  end

  def encryptor
    MESSAGE_ENCRYPTOR
  end

  def metrics_logger
    METRICS_LOGGER
  end
end
