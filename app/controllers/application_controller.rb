class ApplicationController < ActionController::Base
  include Visit::IntegrityChecker

  helper_method :visit
  before_action :add_extra_sentry_metadata
  protect_from_forgery with: :exception
  rescue_from ActiveSupport::MessageVerifier::InvalidSignature, with: :bad_state

  def self.permit_only_trusted_users
    before_action :reject_without_key_or_trusted_ip!
  end

  def reject_without_key_or_trusted_ip!
    unless valid_trusted_users_access_key? || permitted_ip?
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def permitted_ip?
    Rails.configuration.permitted_ips_for_confirmations.
      include?(request.remote_ip)
  end

  def trusted_users_access_key
    Rails.configuration.trusted_users_access_key
  end

  def valid_trusted_users_access_key?
    pad_execution_time 0.1 do
      trusted_users_access_key &&
        params[:key] &&
        trusted_users_access_key == params[:key]
    end
  end

  delegate :prison_name, :visit_id, to: :visit, allow_nil: true

  def add_extra_sentry_metadata
    response['X-Request-Id'] = request_id
    {
      request_id: request_id,
      visit_id: visit_id,
      prison: prison_name
    }.each { |key, value| Raven.extra_context(key => value) if value }
  end

  def request_id
    request.env['action_dispatch.request_id']
  end

  def logstasher_add_visit_id(visit_id)
    LogStasher.request_context[:visit_id] = visit_id
    LogStasher.custom_fields << :visit_id
  end

  def logstasher_add_visit_id_from_session
    logstasher_add_visit_id(visit.visit_id)
  end

  def visit
    session[:visit]
  end

  def encryptor
    MESSAGE_ENCRYPTOR
  end

  def metrics_logger
    METRICS_LOGGER
  end

  def pad_execution_time(execution_time)
    start = Time.zone.now
    result = yield
    stop = Time.zone.now
    sleep execution_time - (stop - start)
    result
  end

  private

  def i18n_flash(type, *partial_key, **options)
    full_key = [
      :controllers, controller_path, *partial_key
    ].join('.')
    flash[type] = I18n.t(full_key, options)
  end

  def set_notice(*partial_key, **options)
    i18n_flash :notice, partial_key, options
  end

  def set_error(*partial_key, **options)
    i18n_flash :error, partial_key, options
  end

  def bad_state(ex)
    render 'shared/bad_state', status: 400
    STATSD_CLIENT.increment('pvb.app.bad_state')
    Raven.capture_exception(ex)
  end
end
