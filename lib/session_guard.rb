module SessionGuard
  extend ActiveSupport::Concern

  def check_if_session_timed_out
    unless visit
      redirect_to(edit_prisoner_details_path, notice: 'Your session timed out because no information was entered for more than 20 minutes.')
      return
    end
    verify_authenticity_token
  end
end

module SessionGuardOnUpdateOnly
  extend ActiveSupport::Concern
  include SessionGuard

  included do
    before_filter :check_if_session_timed_out, only: :update
  end
end

module SessionGuard
  included do
    before_filter :check_if_session_timed_out, only: [:update, :edit]
  end
end
