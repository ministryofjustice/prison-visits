require 'spec_helper'

describe CalculatedMetrics do
  let :nonempty_dataset do
    JSON.parse(File.read("test/test_data/metrics.json"))
  end

  context "empty dataset" do
    subject do
      CalculatedMetrics.new.update({})
    end

    it "calculates total visits" do
      subject.total_visits.should == 0
    end
  end

  context "nonempty dataset" do
    subject do
      CalculatedMetrics.new.update(nonempty_dataset)
    end

    it_behaves_like "a CalculatedMetrics instance"
  end

  context "deserialized instance with nonempty dataset" do
    subject do
      Marshal.load(Marshal.dump(CalculatedMetrics.new.update(nonempty_dataset)))
    end

    it_behaves_like "a CalculatedMetrics instance"
  end
end
