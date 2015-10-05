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
  config.action_mailer.default_url_options = {
    host: "localhost",
    protocol: "http",
    port: "3000"
  }
  config.action_mailer.preview_path = "#{Rails.root}/test/mailers/previews"
  config.active_job.queue_adapter = :sidekiq
  config.smoke_test_email_local_part = ENV['SMOKE_TEST_EMAIL_LOCAL_PART']
  config.smoke_test_email_domain = ENV['SMOKE_TEST_EMAIL_DOMAIN']
  config.session_expire_after = 24.hours

  config.prison_data = YAML.load_file(
    ENV.fetch('PRISON_DATA_FILE', config.prison_data_source)
  ).map{ |p| Prison.new(p) }.sort_by{ |p| p.name }

  # TODO: This is for code hygiene while I move this to the prison model
  config.nomis_ids = config.prison_data.inject(Set[]) do |set, prison|
    set << prison.nomis_id
    set
  end
end
