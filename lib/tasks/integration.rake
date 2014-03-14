namespace :integration do
  task :test => :environment do
    require 'capybara/dsl'
    require 'capybara/poltergeist'
    require './spec/support/features_helper'

    include Capybara::DSL

    Capybara.configure do |config|
      config.run_server = false
      config.default_driver = :poltergeist
      config.app_host = ENV['APP_HOST']
    end

    visit '/prisoner-details?testing=1'

    enter_prisoner_information
    enter_visitor_information

    select '5', from: 'visit[visitor][][number_of_adults]'
    enter_additional_visitor_information(1, :adult)
    enter_additional_visitor_information(2, :adult)
    enter_additional_visitor_information(3, :child)
    enter_additional_visitor_information(4, :child)
    enter_additional_visitor_information(5, :child)
    click_button 'Continue'

    _when = Time.now + 3.days
    begin
      find(:css, _when.strftime("a.BookingCalendar-dayLink[data-date='%Y-%m-%d']")).click
    rescue Capybara::ElementNotFound
      _when += 1.day
      retry
    end

    within(:css, _when.strftime("#date-%Y-%m-%d.is-active")) do
      check('2:00pm 2 hrs')
    end
    click_button 'Continue'

    three_days_from_now = Time.now + 3.days
    find(:xpath, three_days_from_now.strftime("//a[@data-date='%Y-%m-%d']")).click
    check("slot-#{three_days_from_now.strftime('%Y-%m-%d')}-1400-1600")
    click_button 'Continue'
    click_button 'Send request'
  end
end
