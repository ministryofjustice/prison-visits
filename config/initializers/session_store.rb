# Be sure to restart your server when you modify this file.
{key: 'pvbs', expire_after: 20.minutes, httponly: true}.tap do |configuration|
  configuration[:secure] = Rails.env.production?
  PrisonVisits2::Application.config.session_store :cookie_store, configuration
end
