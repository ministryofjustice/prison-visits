require 'metrics_logger'

METRICS_LOGGER = MetricsLogger.new(Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'], log: Rails.logger))

