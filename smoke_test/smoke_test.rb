require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'yaml'
require 'erb'
require 'active_support/core_ext/hash/indifferent_access'

require_relative 'mail_lookup'
require_relative 'steps/base_step'
require_relative 'steps/prisoner_page'
require_relative 'steps/visitors_page'
require_relative 'steps/slots_page'
require_relative 'steps/check_your_request_page'
require_relative 'steps/visitor_booking_receipt'
require_relative 'steps/prison_booking_request'
require_relative 'steps/process_visit_request_page'
require_relative 'steps/visitor_booking_confirmation'
require_relative 'steps/prison_booking_confirmation_copy'
require_relative 'steps/cancel_booking_page'
require_relative 'steps/prison_booking_cancelled'

module SuprressJsConsoleLogging; end
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_logger: SuprressJsConsoleLogging)
end

Capybara.run_server = false
Capybara.current_driver = :poltergeist
Capybara.app_host = ENV.fetch('SMOKE_TEST_APP_HOST')

module SmokeTest
  extend Capybara::DSL

  STEPS = [
    Steps::PrisonerPage,
    Steps::VisitorsPage,
    Steps::SlotsPage,
    Steps::CheckYourRequestPage,
    Steps::VisitorBookingReceipt,
    Steps::PrisonBookingRequest,
    Steps::ProcessVisitRequestPage,
    Steps::PrisonBookingConfirmationCopy,
    Steps::VisitorBookingConfirmation,
    Steps::CancelBookingPage,
    Steps::PrisonBookingCancelled
  ]

  TEST_DATA = YAML.load(ERB.new(File.read('test_data.yml')).result).with_indifferent_access

  def run
    puts 'Beginning Smoke Test..'
    Capybara.reset_sessions!
    visit '/prisoner'
    STEPS.map(&method(:complete))
    puts 'Smoke Test Completed'
  end

  private

  def complete(step)
    current_step = step.new state
    current_step.validate!
    current_step.complete_step
  end

  def state
    @state ||= State.new
  end

  class State < DelegateClass(Hash)
    def initialize
      super({})
      self[:started_at] = Time.now.utc
    end
  end

  extend self
end
