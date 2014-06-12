require 'metrics_logger'

logger = Logger.new(File.join(Rails.root, 'log', 'elasticsearch.log'))

ELASTIC_CLIENT = Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'], log: true, logger: logger)
METRICS_LOGGER = MetricsLogger.new(ELASTIC_CLIENT)


