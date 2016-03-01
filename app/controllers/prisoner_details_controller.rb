class PrisonerDetailsController < ApplicationController
  include CookieGuard
  include SessionGuard::OnUpdate
  include TrimParams

  before_action :logstasher_add_visit_id_from_session, only: :update

  # rubocop:disable Metrics/MethodLength
  def edit
    # Permanently redirect to the new app if we've got to probability 1
    new_app_probability = Rails.configuration.new_app_probability
    if new_app_probability == 1
      redirect_to '/en/request', status: :moved_permanently
    end

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
  # rubocop:enable Metrics/MethodLength

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
    params.require(:prisoner).permit(
      :first_name, :last_name, :number, :prison_name,
      date_of_birth: [:day, :month, :year]
    )
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
end
