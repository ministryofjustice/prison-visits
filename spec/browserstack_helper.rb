# -*- coding: utf-8 -*-
require 'selenium/webdriver'

if username = ENV['BS_USERNAME']
  password = ENV['BS_PASSWORD']
  Capybara.register_driver :browserstack do |app|
    cap = Selenium::WebDriver::Remote::Capabilities.firefox
    cap['browserstack.debug'] = true
    cap['browserstack.tunnel'] = true
    cap['acceptSslCerts'] = true
    
    Capybara::Selenium::Driver.new(app, browser: :remote, url: "https://#{username}:#{password}@hub.browserstack.com/wd/hub", desired_capabilities: cap)
  end
  
  Capybara.default_driver = :browserstack
  Capybara.app_host = 'http://localhost:3000'
  Capybara.run_server = true
  Capybara.server_port = 3000

  # Fire up a tunnel in the background and wait until it is ready.
  r, w = IO.pipe
  pid = spawn("java -jar vendor/BrowserStackTunnel.jar -skipCheck #{ENV['BS_PASSWORD']} localhost,3000,0", out: w)
  while content = r.readline
    break if content == "Press Ctrl-C to exit\n"
    sleep 1
  end
  
  # When finished with the tests, kill the tunnel.
  at_exit do
    Process.kill("HUP", pid)
    Process.wait(pid)
  end
else
  Capybara.default_driver = :selenium
end

module FeatureHelper
  def enter_prisoner_information
    visit '/'
    fill_in 'Prisoner first name', with: 'Jimmy'
    fill_in 'Prisoner last name', with: 'Fingers'
    select '1', from: 'prisoner[date_of_birth(3i)]'
    select 'May', from: 'prisoner[date_of_birth(2i)]'
    select '1969', from: 'prisoner[date_of_birth(1i)]'
    fill_in 'Prisoner number', with: 'a0000aa'
    select 'Rochester', from: 'prisoner[prison_name]'
    click_button 'Continue'
  end

  def enter_visitor_information
    fill_in "Your first name", with: 'Margaret'
    fill_in "Your last name", with: 'Smith'
    select '1', from: 'visit[visitor][][date_of_birth(3i)]'
    select 'June', from: 'visit[visitor][][date_of_birth(2i)]'
    select '1977', from: 'visit[visitor][][date_of_birth(1i)]'
    fill_in "Email address", with: 'test@example.com'
    fill_in "Contact phone number", with: '09998887777'
  end

  def enter_additional_visitor_information(n, kind)
    expect(page).to have_content("Visitor #{n}")
    within "#visitor-#{n}" do
      fill_in "First name", with: 'Andy'
      fill_in "Last name", with: 'Smith'
      if kind == :adult
        select '1', from: 'visit[visitor][][date_of_birth(3i)]'
        select 'June', from: 'visit[visitor][][date_of_birth(2i)]'
        select '1977', from: 'visit[visitor][][date_of_birth(1i)]'
      else
        select '1', from: 'visit[visitor][][date_of_birth(3i)]'
        select 'August', from: 'visit[visitor][][date_of_birth(2i)]'
        select '1999', from: 'visit[visitor][][date_of_birth(1i)]'
      end
    end
  end
end

RSpec.configure do |config|
  config.include FeatureHelper
end

