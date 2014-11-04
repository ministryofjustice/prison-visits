class VisitController < ApplicationController
  before_filter :check_if_cookies_enabled, only: [:update_prisoner_details]
  before_filter :check_if_session_timed_out, only: [:update_prisoner_details, :update_visitor_details, :update_choose_date_and_time, :update_check_your_request]
  before_filter :check_if_session_exists, except: [:prisoner_details, :unavailable, :status]
  helper_method :just_testing?
  helper_method :visit

  def check_if_cookies_enabled
    unless cookies['cookies-enabled']
      redirect_to cookies_disabled_path
      return
    end
  end

  def check_if_session_timed_out
    unless visit
      redirect_to(prisoner_details_path, notice: 'Your session timed out because no information was entered for more than 20 minutes.')
      return
    end
    verify_authenticity_token
  end

  def visit
    session[:visit]
  end

  def check_if_session_exists
    unless visit
      redirect_to(prisoner_details_path)
      return
    end
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
