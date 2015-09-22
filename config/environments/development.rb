PrisonVisits2::Application.configure do
  config.action_mailer.smtp_settings = {
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD']
  }
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_mailer.raise_delivery_errors = false
  config.assets.debug = true
  config.action_mailer.default_url_options = { host: "localhost", protocol: "http", port: "3000" }
  config.action_mailer.preview_path = "#{Rails.root}/test/mailers/previews"

  Rails.application.config.active_job.queue_adapter = :sidekiq
end
