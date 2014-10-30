module ParamUtils
  def self.trim_whitespace_from_values(p)
    case p
    when Hash
      p.inject(p.class.new) do |h, (k, v)|
        if v.is_a?(String)
          h[k] = v.strip
        else
          h[k] = trim_whitespace_from_values(v)
        end
        h
      end
    when Array
      p.map do |v|
        trim_whitespace_from_values(v)
      end
    else
      p
    end
  end
end
