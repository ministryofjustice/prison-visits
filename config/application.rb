require File.expand_path('../boot', __FILE__)
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"
require "active_model"
Bundler.require(:default, Rails.env)
module PrisonVisits2
  class Application < Rails::Application
    config.time_zone = 'London'
    config.app_title = 'Visit someone in prison'
    config.proposition_title = 'Visit someone in prison'
    config.phase = 'live'
    config.product_type = 'service'
    config.feedback_url = 'test@example.com'
    config.ga_id = ENV['GA_TRACKING_ID']
    config.assets.enabled = true
    config.assets.precompile += %w(
      application-ie6.css
      application-ie7.css
      application-ie8.css
      back-office.css
      *.png
    )
    config.prison_data = YAML.load_file(ENV['PRISON_DATA_FILE'] || File.join(Rails.root, 'config', 'prison_data_staging.yml')).with_indifferent_access
    config.nomis_ids = config.prison_data.sort_by do |prison_name, _prison_data|
      prison_name
    end.inject(Set[]) do |set, (_prison_name, prison_data)|
      set << prison_data['nomis_id'] if prison_data['enabled']
      set
    end
    config.bank_holidays = \
      JSON.parse(
        File.read(
          File.join(Rails.root, 'config', 'bank-holidays.json'))).
            fetch('england-and-wales').
            fetch('events').
            map { |event| Date.parse(event['date']) }
    config.metrics_auth_key = ENV['METRICS_AUTH_KEY']
    config.permitted_ips_for_confirmations = (ENV['PRISON_ESTATE_IPS'] || '').split(',')
    config.autoload_paths += %w(lib app/mailers/concerns)
    config.assets.paths << Rails.root.join('vendor', 'assets', 'moj.slot-picker', 'dist', 'stylesheets')
    config.middleware.delete 'ActiveRecord::QueryCache'
    config.session_expire_after = 20.minutes
  end
end
