SERVICE_DOMAIN = (url = ENV['SERVICE_URL']) ? URI.parse(url).host : nil

PrisonVisits2::Application.config.session_store :cookie_store,
  key: 'pvbs',
  expire_after: 20.minutes,
  httponly: true,
  max_age: 20.minutes,
  domain: SERVICE_DOMAIN,
  secure: Rails.env.production?
