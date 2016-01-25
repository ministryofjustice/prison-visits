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
    config.unsubscribe_url =
      '<https://www.prisonvisits.service.gov.uk/unsubscribe>'
    config.ga_id = ENV['GA_TRACKING_ID']
    config.assets.enabled = true
    config.assets.precompile += %w(
      application-ie6.css
      application-ie7.css
      application-ie8.css
      back-office.css
      *.png
    )
    config.prison_data_source = \
      File.join(Rails.root, 'config', 'prison_data.yml')
    config.bank_holidays = \
      JSON.parse(
        File.read(
          File.join(Rails.root, 'config', 'bank-holidays.json'))).
            fetch('england-and-wales').
            fetch('events').
            map { |event| Date.parse(event['date']) }
    config.trusted_users_access_key = ENV['TRUSTED_USERS_ACCESS_KEY']
    config.permitted_ips_for_confirmations =
      (ENV['PRISON_ESTATE_IPS'] || '').split(',')

    config.autoload_paths += %w(lib app/mailers/concerns)

    config.assets.paths << Rails.root.join('vendor',
      'assets', 'moj.slot-picker', 'dist', 'stylesheets')
    config.middleware.delete 'ActiveRecord::QueryCache'
    config.session_expire_after = 20.minutes
    config.new_app_probability = ENV.fetch('NEW_APP_PROBABILITY', 0).to_f
  end
end
