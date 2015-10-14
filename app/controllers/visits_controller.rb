class VisitsController < ApplicationController
  include CookieGuard
  include SessionGuard::OnEditAndUpdate
  before_action :ensure_visit_integrity, only: [:edit, :update]
  before_action :logstasher_add_visit_id_from_session, only: :update

  def update
    @token = encryptor.encrypt_and_sign(visit)
    PrisonMailer.booking_request_email(visit, @token).deliver_later
    VisitorMailer.booking_receipt_email(visit, @token).deliver_later

    STATSD_CLIENT.increment("pvb.app.visit_request_submitted")

    metrics_logger.record_visit_request(visit)
    redirect_to show_visit_path(state: @token)
    reset_session
  end

  def show
    session[:visit] = encryptor.decrypt_and_verify(params[:state])
    logstasher_add_visit_id(visit.visit_id)
    render
    reset_session
  end
end
