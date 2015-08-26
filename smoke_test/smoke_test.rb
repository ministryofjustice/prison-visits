require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'yaml'
require 'erb'
require 'active_support/core_ext/hash/indifferent_access'

require_relative 'steps/base_step'
require_relative 'steps/prisoner_page'
require_relative 'steps/visitors_page'
require_relative 'steps/slots_page'

module SuprressJsConsoleLogging; end
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_logger: SuprressJsConsoleLogging)
end

Capybara.run_server = false
Capybara.current_driver = :poltergeist
Capybara.app_host = ENV.fetch('SMOKE_TEST_APP_HOST')

module SmokeTest
  extend Capybara::DSL

  STEPS = [Steps::PrisonerPage, Steps::VisitorsPage, Steps::SlotsPage]

  TEST_DATA = YAML.load(ERB.new(File.read('test_data.yml')).result).with_indifferent_access

  def run
    puts 'Beginning Smoke Test..'
    Capybara.reset_sessions!
    start_form
    STEPS.map(&method(:complete))
    puts 'Smoke Test Completed'
  end

  private

  def complete(step)
    current_step = step.new state
    current_step.assert_validity!
    current_step.complete_step
  end

  def state
    @state ||= State.new
  end

  def start_form
    visit '/'
    click_link 'Start now'
  end

  class State < DelegateClass(Hash)
    def initialize
      super({})
      self[:started_at] = Time.now.utc
    end
  end

  extend self
end
