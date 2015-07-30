require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails' do
  add_filter '/gem/'
end

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 10
  config.order = :random

  Kernel.srand config.seed

  config.include Module.new {
    require 'rspec/core/shared_context'
    extend ::RSpec::Core::SharedContext

    let :sample_visit do
      Visit.new.tap do |v|
        v.visit_id = SecureRandom.hex
        v.slots = [Slot.new(date: '2013-07-07', times: "1400-1600")]
        v.prisoner = Prisoner.new.tap do |p|
          p.date_of_birth = Date.new(2013, 6, 30)
          p.first_name = 'Jimmy'
          p.last_name = 'Harris'
          p.prison_name = 'Rochester'
          p.number = 'a0000aa'
        end
        v.visitors = [Deferred::Visitor.new(email: 'visitor@example.com', date_of_birth: Date.new(1918, 11, 11), first_name: 'Mark', last_name: 'Harris'),
                      Deferred::Visitor.new(date_of_birth: Date.new(1967, 3, 3), first_name: 'Joan', last_name: 'Harris')]
        v.vo_number = '87654321'
      end
    end
  }

  config.include Utilities

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
