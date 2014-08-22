class CacheRefresher
  class Dataset < Struct.new(:version, :dataset)
    def prisons
      dataset.keys
    end

    def [](prison)
      dataset[prison]
    end
  end

  INDEX_NAME = :pvb

  def initialize(elastic_client, prisons)
    @elastic_client = elastic_client
    @prisons = prisons
  end

  def precalculate_from_scratch(now = Time.now)
    dataset = empty_dataset
    dataset.each_pair do |prison_name, metrics|
      metrics.update(query(prison_name, until_when: now))
    end
    Dataset.new(now, dataset)
  end

  def fetch
    if version = cache_read('current_version')
      dataset = @prisons.inject({}) do |h, prison_name|
        h[prison_name] = cache_read([prison_name, version].join) || (raise); h
      end
      Dataset.new(version, dataset)
    end
  end
  
  def update(dataset_instance, now)
    dataset_instance.dataset.each do |prison_name, metrics|
      metrics.update(query(prison_name, since_when: dataset_instance.version, until_when: now))
    end
    Dataset.new(now, dataset_instance.dataset)
  end

  def empty_dataset
    @prisons.inject({}) do |h, prison_name|
      h[prison_name] = CalculatedMetrics.new; h
    end
  end

  def cache_read(key)
    Rails.cache.read(key)
  end

  def cache_write(key, value)
    Rails.cache.write(key, value)
  end

  def query(prison_name, until_when: nil, since_when: nil)
    query = {index: INDEX_NAME, q: "prison:(\"#{prison_name}\")", size: 1_000_000, sort: 'timestamp:asc'}
    query[:q] += " AND timestamp:<=#{until_when.to_i}" if until_when
    query[:q] += " AND timestamp:>#{since_when.to_i}" if since_when
    @elastic_client.search(query)
  end

  def self.store(dataset_instance)
    version = dataset_instance.version
    dataset_instance.dataset.each do |prison_name, metrics|
      cache_write([prison_name, version].join, metrics)
    end
    cache_write('current_version', version)
  end

  def self.cron_run
    now = Time.now
    version, dataset = new(ELASTIC_CLIENT, Rails.configuration.prison_data.keys.sort).update(now)
    store(now, dataset)
  end
end
