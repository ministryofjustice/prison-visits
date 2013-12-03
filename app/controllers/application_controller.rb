class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :visit
  http_basic_authenticate_with name: ENV['HTTP_USER'], password: ENV['HTTP_PASSWORD'] if Rails.env.production?

  def visit
    session[:visit] ||= Visit.new(prisoner: Prisoner.new, visitors: [Visitor.new], slots: [])
  end
end
