class ApplicationController < ActionController::Base
  helper_method :visit
  before_filter :add_extra_sentry_metadata
  protect_from_forgery with: :exception
  rescue_from ActiveSupport::MessageVerifier::InvalidSignature, with: :bad_state

  def self.permit_only_from_prisons
    before_filter :reject_untrusted_ips!
  end

  def self.permit_only_from_prisons_or_with_key
    before_filter :reject_untrusted_ips_and_without_key!
  end

  def self.permit_only_with_key
    before_filter :reject_without_key!
  end

  def reject!
    raise ActionController::RoutingError.new('Go away')
  end

  def reject_untrusted_ips!
    unless Rails.configuration.permitted_ips_for_confirmations.
      include?(request.remote_ip)
      reject!
    end
  end

  def reject_untrusted_ips_and_without_key!
    unless Rails.configuration.metrics_auth_key.secure_compare(params[:key])
      reject_untrusted_ips!
    end
  end

  def reject_without_key!
    unless Rails.configuration.metrics_auth_key.secure_compare(params[:key])
      reject!
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

  def ensure_visit_integrity
    unless visit && visit.prisoner && visit.prison_name.present?
      flash[:notice] = I18n.t(
        :ensure_visit_integrity,
        scope: 'controllers.shared'
      )
      redirect_to edit_prisoner_details_path
    end
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
