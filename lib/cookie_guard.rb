module CookieGuard
  extend ActiveSupport::Concern

  included do
    before_filter :check_if_cookies_enabled, only: :update
  end

  def check_if_cookies_enabled
    unless cookies['cookies-enabled']
      redirect_to cookies_disabled_path
      return
    end
  end
end
