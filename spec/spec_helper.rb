# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

module HelperMethods
  def sample_visit
    Visit.new.tap do |v|
      v.visit_id = "ABC"
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
    end
  end
end

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  config.include HelperMethods

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
