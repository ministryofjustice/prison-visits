module KillswitchGuard
  extend ActiveSupport::Concern

  included do
    before_filter :check_for_killswitch
  end

  def check_for_killswitch
    if killswitch_active?
      reset_session
      redirect_to edit_prisoner_details_path
    end
  end

  def killswitch_active?
    ENV['API_KILLSWITCH']
  end
end
