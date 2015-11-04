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
    when Hash   then trim_hash(obj)
    when Array  then obj.map { |v| strip_whitespace(v) }
    when String then obj.strip
    else
      obj
    end
  end

  def trim_hash(obj)
    obj.inject(obj.class.new) { |h, (k, v)|
      h[k] = strip_whitespace(v)
      h
    }
  end
end
