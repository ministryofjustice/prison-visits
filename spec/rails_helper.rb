# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/core/shared_context'

ActiveRecord::Migration.maintain_test_schema!

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  config.include Module.new {
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
        v.visitors = [
          Deferred::Visitor.new(
            email: 'visitor@example.com',
            date_of_birth: Date.new(1918, 11, 11),
            first_name: 'Mark',
            last_name: 'Harris'
          ),
          Deferred::Visitor.new(
            date_of_birth: Date.new(1967, 3, 3),
            first_name: 'Joan',
            last_name: 'Harris'
          )
        ]
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
