require 'rack-proxy'

class NewAppProxy < Rack::Proxy
  def initialize(options)
    url = URI.parse(options.fetch(:url))
    @hostname = "#{url.host}:#{url.port}"

    super
  end

  def rewrite_env(env)
    env["HTTP_HOST"] = @hostname
    env
  end
end
