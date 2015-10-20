module TrimParams
  extend ActiveSupport::Concern

  included do
    before_action :strip_parameter_whitespace
  end

  private

  def strip_parameter_whitespace
    self.params = strip_whitespace(params)
  end

  def strip_whitespace(obj)
    case obj
    when Hash
      obj.inject(obj.class.new) { |h, (k, v)|
        h[k] = strip_whitespace(v)
        h
      }
    when Array
      obj.map { |v| strip_whitespace(v) }
    when String
      obj.strip
    else
      obj
    end
  end
end
