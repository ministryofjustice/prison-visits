class Deferred::VisitsController < ApplicationController
  include CookieGuard
  include SessionGuard

  def edit
  end

  def update
    @token = encryptor.encrypt_and_sign(visit)
    PrisonMailer.booking_request_email(visit, @token).deliver
    VisitorMailer.booking_receipt_email(visit).deliver

    metrics_logger.record_visit_request(visit)
    redirect_to deferred_visit_path
  end

  def show
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
