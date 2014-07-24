# Be sure to restart your server when you modify this file.
{key: 'pvbs', expire_after: 20.minutes, httponly: true, max_age: 20.minutes.to_i.to_s}.tap do |configuration|
  configuration[:secure] = Rails.env.production?
  PrisonVisits2::Application.config.session_store :cookie_store, configuration
end
