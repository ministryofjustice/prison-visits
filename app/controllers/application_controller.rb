class ApplicationController < ActionController::Base
  helper_method :visit

  def visit
    session[:visit] ||= Visit.new(prisoner: Prisoner.new, visitors: [Visitor.new], slots: [], visit_id: SecureRandom.hex)
  end
end
