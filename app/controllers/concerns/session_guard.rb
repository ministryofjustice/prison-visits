module SessionGuard
  module Shared
    def check_if_session_timed_out
      unless visit
        flash[:notice] = I18n.t(:session_timed_out, scope: 'controllers.shared')
        redirect_to edit_prisoner_details_path
        return
      end
      verify_authenticity_token
    end
  end

  module OnUpdate
    extend ActiveSupport::Concern
    include Shared

    included do
      before_action :check_if_session_timed_out, only: :update
    end
  end

  module OnEditAndUpdate
    extend ActiveSupport::Concern
    include Shared

    included do
      before_action :check_if_session_timed_out, only: [:update, :edit]
    end
  end
end
