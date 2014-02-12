class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :visit

  if Rails.env.production? && ENV['APP_PLATFORM'] != 'production'
    http_basic_authenticate_with name: ENV['HTTP_USER'], password: ENV['HTTP_PASSWORD']
  end

  def visit
    session[:visit] ||= Visit.new(prisoner: Prisoner.new, visitors: [Visitor.new], slots: [], visit_id: SecureRandom.hex)
  end
end
