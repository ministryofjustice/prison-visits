class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :visit

  def visit
    session[:visit] ||= Visit.new(prisoner: Prisoner.new, visitors: 6.times.collect { Visitor.new }, slots: [])
  end
end
