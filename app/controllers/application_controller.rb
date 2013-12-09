class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :visit

  def visit
    session[:visit] ||= Visit.new(prisoner: Prisoner.new, visitors: [Visitor.new], slots: [])
  end
end
