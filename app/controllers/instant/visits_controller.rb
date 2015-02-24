class Instant::VisitsController < ApplicationController
  include CookieGuard
  include SessionGuard
  include KillswitchGuard

  def update
    token = encryptor.encrypt_and_sign(visit)
    VisitorMailer.instant_confirmation_email(visit).deliver

    metrics_logger.record_instant_visit(visit)
    redirect_to instant_show_visit_path(state: token)
    reset_session
  end

  def show
    session[:visit] = encryptor.decrypt_and_verify(params[:state])
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
