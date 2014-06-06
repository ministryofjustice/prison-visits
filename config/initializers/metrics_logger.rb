require 'metrics_logger'

logger = Logger.new(File.join(Rails.root, 'log', 'elasticsearch.log'))

METRICS_LOGGER = MetricsLogger.new(Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'], log: true, logger: logger))


