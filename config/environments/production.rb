PrisonVisits2::Application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_files = false
  config.assets.js_compressor = :uglifier
  config.assets.compile = false
  config.assets.digest = true
  config.assets.version = '1.0'
  config.log_level = :info
  config.assets.precompile += %w( metrics.css metrics.js )
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.action_mailer.smtp_settings = {
    address: ENV['SMTP_HOSTNAME'],
    port: ENV['SMTP_PORT'],
    domain: ENV['SMTP_DOMAIN'],
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    authentication: :login,
    enable_starttls_auto: true
  }
  config.logstasher.enabled = true
  config.logstasher.suppress_app_log = true
  config.logstasher.log_controller_parameters = true
  config.logstasher.logger_path = File.join(Rails.root, "log", "logstash_production.json")
  config.action_mailer.default_url_options = { host: ENV["SERVICE_URL"] || (raise "Missing SERVICE_URL"), protocol: "https" }
  config.active_job.queue_adapter = :sidekiq
  config.smoke_test_email_local_part = ENV['SMOKE_TEST_EMAIL_LOCAL_PART']
  config.smoke_test_email_domain = ENV['SMOKE_TEST_EMAIL_DOMAIN']
end
