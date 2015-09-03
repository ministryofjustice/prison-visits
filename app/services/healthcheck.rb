require 'sidekiq/api'

class Healthcheck
  STALENESS_THRESHOLD = 10.minutes

  def initialize
    @queues = {}
  end

  def ok?
    checks.values.all?
  end

  def checks
    {
      database: database_active?,
      mailers: fresh?('mailers'),
      zendesk: fresh?('zendesk')
    }
  end

  def queues
    {
      mailers: queue_info('mailers'),
      zendesk: queue_info('zendesk'),
    }
  end

  private

  def queue(name)
    @queues[name] ||= Sidekiq::Queue.new(name)
  end

  def queue_info(queue_name)
    q = queue(queue_name)
    {
      oldest: oldest_item_created_at(q),
      count: q.count
    }
  rescue Exception
    { oldest: nil, count: 0 }
  end

  def oldest_item_created_at(q)
    q.any? ? q.first.created_at : nil
  end

  def fresh?(queue_name)
    q = queue(queue_name)
    created_at = oldest_item_created_at(q)
    if created_at
      created_at > STALENESS_THRESHOLD.ago
    else
      true
    end
  rescue Exception
    false
  end

  def database_active?
    ActiveRecord::Base.connection.active?
  rescue Exception
    false
  end
end
