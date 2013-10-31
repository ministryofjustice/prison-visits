class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :visit
  before_filter :authenticate
  
  def authenticate
    unless Rails.env.development?
      authenticate_with_http_basic do |username, password|
          username == ENV['HTTP_USER'] && password == ENV['HTTP_PASSWORD']
      end
    end
  end

  def visit
    session[:visit] ||= Visit.new(prisoner: Prisoner.new, visitors: [Visitor.new], slots: [])
  end
end
