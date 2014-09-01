require 'spec_helper'

describe CacheRefresher do
  let :client do
    double('client')
  end

  let :prisons do
    ['Rochester']
  end

  let :random_key do
    SecureRandom.hex
  end

  let :random_value do
    SecureRandom.hex
  end

  subject do
    CacheRefresher.new(client, prisons)
  end

  context "always" do
    it "is attached to Rails.cache" do
      Rails.cache.should_receive(:read).with(random_key)
      CacheRefresher.cache_read(random_key)

      Rails.cache.should_receive(:write).with(random_key, random_value)
      CacheRefresher.cache_write(random_key, random_value)
    end

    it "builds an empty dataset" do
      subject.empty_dataset.keys.should == prisons
    end

    it "builds queries correctly" do
      client.should_receive(:search).with(index: :pvb, q: "prison:(\"Rochester\")", size: 1_000_000, sort: "timestamp:asc")
      subject.query('Rochester')

      client.should_receive(:search).with(index: :pvb, q: "prison:(\"Rochester\") AND timestamp:<=0", size: 1_000_000, sort: "timestamp:asc")
      subject.query('Rochester', until_when: Time.at(0))

      client.should_receive(:search).with(index: :pvb, q: "prison:(\"Rochester\") AND timestamp:>0", size: 1_000_000, sort: "timestamp:asc")
      subject.query('Rochester', since_when: Time.at(0))

      client.should_receive(:search).with(index: :pvb, q: "prison:(\"Rochester\") AND timestamp:<=0 AND timestamp:>0", size: 1_000_000, sort: "timestamp:asc")
      subject.query('Rochester', since_when: Time.at(0), until_when: Time.at(0))
    end
  end

  context "no data exists in the cache" do
    before :each do
      Timecop.freeze
    end

    before :each do
      Timecop.return
    end
    
    it "precalculates the data from scratch" do
      subject.should_receive(:query).with('Rochester', until_when: 1).and_return([])
      subject.precalculate_from_scratch(1)
    end

    it "attempts to fetch data from cache, but fails" do
      subject.should_receive(:query).never
      subject.fetch.should be_nil
    end
  end

  context "partial data exists in the cache" do
    before :each do
      Timecop.freeze
    end

    before :each do
      Timecop.return
    end

    it "retrieves data from the cache" do
      CacheRefresher.should_receive(:cache_read).with('current_version').and_return(0)
      CacheRefresher.should_receive(:cache_read).with(['Rochester', 0].join).and_return(CalculatedMetrics.new)
      subject.should_receive(:query).never
      subject.fetch.should_not be_nil
    end

    it "updates data from the cache" do
      subject.should_receive(:query).with('Rochester', since_when: 0, until_when: 1).and_return([])
      subject.update(CacheRefresher::Dataset.new(0, {'Rochester' => CalculatedMetrics.new}), 1).should_not be_nil
    end
  end
end
