PrisonVisits2::Application.configure do
  config.cache_classes = true
  config.eager_load = false
  config.serve_static_files   = true
  config.static_cache_control = "public, max-age=3600"
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = true
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.delivery_method = :test
  config.action_mailer.smtp_settings = {}
  config.active_support.deprecation = :stderr
  config.action_mailer.default_url_options = {
    host: "localhost",
    protocol: "https",
    port: "3000"
  }
  config.active_job.queue_adapter = :test

  config.smoke_test_email_local_part = 'user'
  config.smoke_test_email_domain = 'example.com'
  config.action_view.raise_on_missing_translations = true
end
