require 'rails_helper'

if ENV.key?('BS_BROWSER')
  require 'selenium/webdriver'
  ENV['SMTP_SENDER'] = 'test@example.com'
  username = ENV.fetch('BS_USERNAME')
  password = ENV.fetch('BS_PASSWORD')

  Capybara.register_driver :browserstack do |app|
    capabilities = JSON.parse(ENV.fetch('BS_BROWSER'))

    ['device', 'browser_version'].each do |key|
      capabilities.delete(key) unless capabilities[key]
    end

    capabilities['project'] = 'PVBE'
    capabilities['build'] = `git rev-parse HEAD`

    capabilities['browserstack.debug'] = true
    capabilities['browserstack.tunnel'] = true
    capabilities['acceptSslCerts'] = true

    Capybara::Selenium::Driver.new(
      app,
      browser: :remote,
      url: "https://#{username}:#{password}@hub.browserstack.com/wd/hub",
      desired_capabilities: capabilities
    )
  end

  Capybara.default_driver = :browserstack
  Capybara.app_host = 'http://localhost:3000'
  Capybara.run_server = false
else
  require 'capybara/rspec'
  require 'capybara/poltergeist'
  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist
  Capybara.default_wait_time = 3
end
