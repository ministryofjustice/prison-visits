ELASTIC_CLIENT = Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'])
METRICS_LOGGER = MetricsLogger.new
