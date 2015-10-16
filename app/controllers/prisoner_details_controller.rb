class PrisonerDetailsController < ApplicationController
  include CookieGuard
  include SessionGuard::OnUpdate
  include TrimParams
  before_action :logstasher_add_visit_id_from_session, only: :update

  def edit
    session[:visit] ||= new_session
    logstasher_add_visit_id(visit.visit_id)
    response.set_cookie(
      'cookies-enabled',
      value: 1,
      secure: request.ssl?,
      httponly: true,
      domain: service_domain,
      path: '/'
    )
  end

  def update
    if (visit.prisoner = Prisoner.new(prisoner_params)).valid?
      redirect_to edit_visitors_details_path
    else
      if visit.prisoner.errors[:number].any?
        STATSD_CLIENT.increment('pvb.app.invalid_prisoner_number')
      end
      redirect_to edit_prisoner_details_path
    end
  end

  def prisoner_params
    dob = [:'date_of_birth(3i)', :'date_of_birth(2i)', :'date_of_birth(1i)']
    date_of_birth = dob.map { |key| params[:prisoner].delete(key).to_i }
    params[:prisoner][:date_of_birth] = Date.new(*date_of_birth.reverse)
    trim_whitespace_from_params %i[
      first_name last_name date_of_birth number prison_name
    ]
  rescue ArgumentError
    trim_whitespace_from_params %i[first_name last_name number prison_name]
  end

  def new_session
    Visit.new(
      visit_id: SecureRandom.hex,
      prisoner: Prisoner.new,
      visitors: [],
      slots: []
    )
  end

  def service_domain
    SERVICE_DOMAIN
  end

  private

  def trim_whitespace_from_params(whitelisted_params)
    trim_whitespace_from_values(
      params.require(:prisoner).permit(*whitelisted_params)
    )
  end
end
