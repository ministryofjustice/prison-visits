class Instant::VisitsController < ApplicationController
  include CookieGuard
  include SessionGuard::OnEditAndUpdate
  include KillswitchGuard
  before_action :ensure_visit_integrity, only: [:edit, :update]
  before_filter :logstasher_add_visit_id_from_session, only: :update

  def update
    token = encryptor.encrypt_and_sign(visit)
    VisitorMailer.instant_confirmation_email(visit).deliver_now

    metrics_logger.record_instant_visit(visit)
    redirect_to instant_show_visit_path(state: token)
    reset_session
  end

  def show
    session[:visit] = encryptor.decrypt_and_verify(params[:state])
    logstasher_add_visit_id(visit.visit_id)
    render
    reset_session
  end
end
