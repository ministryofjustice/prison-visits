namespace :integration do
  task :test => :environment do
    require 'capybara/dsl'
    require 'capybara/poltergeist'
    require './spec/support/features_helper'

    include Capybara::DSL
    include FeaturesHelper

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

    yesterday = Time.now - 1.day
    find(:css, yesterday.strftime("a.BookingCalendar-dayLink[data-date='%Y-%m-%d']")).click
    page.should have_content("It is not possible to book a visit in the past.")

    tomorrow = Time.now + 1.day
    find(:css, tomorrow.strftime("a.BookingCalendar-dayLink[data-date='%Y-%m-%d']")).click
    page.should have_content('You can only book a visit 3 days in advance.')

    a_month_from_now = Time.now + 29.days
    find(:css, a_month_from_now.strftime("a.BookingCalendar-dayLink[data-date='%Y-%m-%d']")).click
    page.should have_content('You can only book a visit in the next 28 days.')

    _when = Time.now + 3.days
    begin
      find(:css, _when.strftime("a.BookingCalendar-dayLink[data-date='%Y-%m-%d']")).click
    rescue Capybara::ElementNotFound
      _when += 1.day
      retry
    end

    within(:css, _when.strftime("#date-%Y-%m-%d.is-active")) do
      page.should have_content(_when.strftime("%A %e %B"))
      check('2:00pm 2 hrs')
    end

    click_button 'Continue'

    page.should have_content('Check your request')

    click_button 'Send request'
    page.should have_content('Your visit request has been sent')
  end
end
