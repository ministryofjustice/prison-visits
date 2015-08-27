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
      mailers: !old_items?(queue('mailers')),
      zendesk: !old_items?(queue('zendesk'))
    }
  end

  def queues
    {
      mailers: queue_info(queue('mailers')),
      zendesk: queue_info(queue('zendesk')),
    }
  end

  private

  def queue(name)
    @queues[name] ||= Sidekiq::Queue.new(name)
  end

  def queue_info(q)
    {
      oldest: oldest_item_created_at(q),
      count: q.count
    }
  end

  def oldest_item_created_at(q)
    q.any? ? q.first.created_at : nil
  end

  def old_items?(q)
    created_at = oldest_item_created_at(q)
    if created_at
      created_at < STALENESS_THRESHOLD.ago
    else
      false
    end
  end

  def database_active?
    ActiveRecord::Base.connection.active?
  rescue PG::ConnectionBad
    false
  end
end
