ZENDESK_CLIENT = ZendeskAPI::Client.new do |config|
  config.url = 'https://ministryofjustice.zendesk.com/api/v2'
  config.username = ENV['ZENDESK_USERNAME']
  config.token = ENV['ZENDESK_TOKEN']
  config.retry = true

  require 'logger'
  config.logger = Logger.new("log/zendesk.log")
  config.logger.level = Logger::DEBUG
end
