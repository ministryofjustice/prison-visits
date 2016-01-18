source 'https://rubygems.org'

gem 'rails'
gem 'haml-rails'
gem 'sass-rails'
gem 'uglifier', '>= 1.3.0'
gem 'unicorn'
gem 'govuk_frontend_toolkit', '2.0.1'
gem 'moj_template', '0.21.0'
gem 'coffee-rails'
gem 'zendesk_api'
gem 'mail'
gem 'elasticsearch'
gem 'logstasher', git: 'https://github.com/shadabahmed/logstasher.git', branch: 'master'
gem 'sentry-raven'
gem 'redcarpet'
gem 'prison_staff_info', git: 'git@github.com:ministryofjustice/prison_staff_info.git', branch: 'master' unless ENV['EXCLUDE_PRIVATE_GEM']
gem 'pg'
gem 'sendgrid_toolkit'
gem 'sidekiq'
gem 'statsd-ruby', require: 'statsd'
gem 'curb'
gem 'string_scrubber', '>= 0.2.0'
gem 'virtus'
gem 'sinatra'
gem 'rack-proxy'

group :test do
  gem 'codeclimate-test-reporter'
  gem 'simplecov', '~> 0.7.1', require: false
  gem 'simplecov-rcov', require: false
  gem 'timecop'
  gem 'rubyzip'
  gem 'selenium-webdriver'
  gem 'capybara'
  gem 'rspec_junit_formatter'
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'poltergeist'
  gem 'chromedriver-helper'
  gem 'database_cleaner'
  gem 'rspec-html-matchers'
  gem 'launchy'
  gem 'webmock'
  gem 'fuubar'
end

group :test, :development do
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'parallel'
  gem 'rspec-rails'
end
