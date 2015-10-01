service_url = ENV['SERVICE_URL']
SERVICE_DOMAIN = (service_url) ? URI.parse(service_url).host : nil

PrisonVisits2::Application.config.session_store :cookie_store,
  key: 'pvbs',
  expire_after: 20.minutes,
  httponly: true,
  domain: SERVICE_DOMAIN,
  secure: Rails.env.production?
