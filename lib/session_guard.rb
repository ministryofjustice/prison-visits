module SessionGuard
  extend ActiveSupport::Concern

  included do
    before_filter :check_if_session_timed_out, only: :update
    before_filter :check_if_session_exists, only: :update
  end

  def check_if_session_timed_out
    unless visit
      redirect_to(edit_prisoner_details_path, notice: 'Your session timed out because no information was entered for more than 20 minutes.')
      return
    end
    verify_authenticity_token
  end

  def check_if_session_exists
    unless visit
      redirect_to(edit_prisoner_details_path)
      return
    end
  end
end
