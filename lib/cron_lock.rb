class CronLock
  KEY = 'cron_runner_lock'

  def initialize(redis_client=Redis.new(url: ENV['REDIS_URL']))
    @redis_client = redis_client
  end

  def run(&block)
    lock(&block)
  end

  def lock(&block)
    if @redis_client.set(KEY, value, nx: true)
      begin
        block.call
      ensure
        @redis_client.del(KEY)
      end
    end
  end

  def run_internal
    now = Time.now
    version, dataset = CacheRefresher.new(ELASTIC_CLIENT, Rails.configuration.prison_data.keys.sort).update(now)
    CacheRefresher.store(now, dataset)
    finish
  end

  def value
    [Process.pid, Time.now].join('///')
  end
end
