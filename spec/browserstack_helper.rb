# -*- coding: utf-8 -*-
require 'spec_helper'
require 'selenium/webdriver'

ENV['SMTP_SENDER'] = 'test@example.com'

if username = ENV['BS_USERNAME']
  password = ENV['BS_PASSWORD']

  Capybara.register_driver :browserstack do |app|
    cap = if ENV['BS_BROWSER']
      JSON.parse(ENV['BS_BROWSER'])
    else
      Selenium::WebDriver::Remote::Capabilities.firefox
    end

    ['device', 'browser_version'].each do |key|
      cap.delete(key) if cap[key].nil? && cap.is_a?(Hash)
    end

    cap['project'] = 'PVBE'
    cap['build'] = `git rev-parse HEAD`

    cap['browserstack.debug'] = true
    cap['browserstack.tunnel'] = true
    cap['acceptSslCerts'] = true
    
    Capybara::Selenium::Driver.new(app, browser: :remote, url: "https://#{username}:#{password}@hub.browserstack.com/wd/hub", desired_capabilities: cap)
  end
  
  Capybara.default_driver = :browserstack
  Capybara.app_host = 'http://localhost:3000'
  Capybara.run_server = false
else
  Capybara.default_driver = :selenium
end

