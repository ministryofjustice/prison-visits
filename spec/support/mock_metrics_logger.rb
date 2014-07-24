require 'metrics_logger'

class MockMetricsLogger < MetricsLogger
  attr_reader :content

  def initialize
    @content = []
  end

  def <<(message)
    @content << message
  end
end
