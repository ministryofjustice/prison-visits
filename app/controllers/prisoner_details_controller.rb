class PrisonerDetailsController < ApplicationController
  before_filter :check_if_cookies_enabled, only: :update
  helper_method :visit

  def edit
    session[:visit] ||= new_session
    logstasher_add_visit_id(visit.visit_id)
    response.set_cookie 'cookies-enabled', value: 1, secure: request.ssl?, httponly: true, domain: service_domain
  end

  def update
    if (visit.prisoner = Prisoner.new(prisoner_params)).valid?
      redirect_to edit_deferred_visitors_details_path
    else
      redirect_to edit_prisoner_details_path
    end
  end

  def check_if_cookies_enabled
    unless cookies['cookies-enabled']
      redirect_to cookies_disabled_path
      return
    end
  end

  def visit
    session[:visit]
  end

  def prisoner_params
    dob = [:'date_of_birth(3i)', :'date_of_birth(2i)', :'date_of_birth(1i)']
    if params[:date_of_birth_native].present?
      params[:prisoner][:date_of_birth] = Date.parse(params[:date_of_birth_native])
      dob.map{|d| params[:prisoner].delete(d)}
    else
      date_of_birth = dob.map do |key|
        params[:prisoner].delete(key).to_i
      end
      params[:prisoner][:date_of_birth] = Date.new(*date_of_birth.reverse)
    end
    ParamUtils.trim_whitespace_from_values(params.require(:prisoner).permit(:first_name, :last_name, :date_of_birth, :number, :prison_name))
  rescue ArgumentError
    ParamUtils.trim_whitespace_from_values(params.require(:prisoner).permit(:first_name, :last_name, :number, :prison_name))
  end

  def new_session
    Visit.new(visit_id: SecureRandom.hex, prisoner: Prisoner.new, visitors: [Visitor.new])
  end

  def service_domain
    'lol.biz.info'
  end
end
