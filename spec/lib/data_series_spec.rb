require 'spec_helper'

describe CalculatedMetrics::DataSeries do
  context "many data" do
    subject do
      CalculatedMetrics::DataSeries.from_array(1_000_000.times.map { rand })
    end
    
    it "such percentiles" do
      (1..100).step(5) do |p|
        subject.percentile(p).should < p * 0.01 + 0.001
      end
    end
  end

  context "little data is available" do
    it "calculates doesn't return a value" do
      (1..15).each do |n|
        CalculatedMetrics::DataSeries.from_array(n.times.map { rand }).percentile.should be_nil
      end
    end
  end
end
