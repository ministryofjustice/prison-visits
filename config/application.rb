require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"
require "active_model"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module PrisonVisits2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'London'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # app title appears in the header bar
    config.app_title = 'Visit someone in prison'
    # Proposition Title (Populates proposition header)
    config.proposition_title = 'Visit someone in prison'
    # Current Phase (Sets the current phase and the colour of phase tags)
    # Presumed values: alpha, beta, live
    config.phase = 'live'
    # Product Type (Adds class to body based on service type)
    # Presumed values: information, service
    config.product_type = 'service'
    # Feedback URL (URL for feedback link in phase banner)
    config.feedback_url = 'test@example.com'
    # Google Analytics ID (Tracking ID for the service)
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
    config.nomis_ids = config.prison_data.sort_by do |prison_name, prison_data|
      prison_name
    end.inject(Set[]) do |set, (prison_name, prison_data)|
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
  end
end
