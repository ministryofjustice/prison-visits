require 'spec_helper'

describe CalculatedMetrics do
  let :nonempty_dataset do
    JSON.parse(File.read("test/test_data/metrics.json"))
  end

  let :prison do
    'Rochester'
  end
  
  context "empty dataset" do
    subject do
      CalculatedMetrics.from_elasticsearch([])
    end

    it "lists prisons" do
      subject.prisons.should == []
    end

    it "calculates total visits" do
      subject.total_visits.should == {}
    end
  end

  context "nonempty dataset" do
    subject do
      CalculatedMetrics.from_elasticsearch(nonempty_dataset)
    end

    it "lists prisons" do
      subject.prisons.should == ["Aylesbury", "Brinsford", "Bullingdon", "Cardiff", "Cookham Wood", "Deerbolt", "Drake Hall", "Durham", "Featherstone", "Foston Hall", "Gartree", "Glen Parva", "Hewell", "Liverpool", "Norwich (A, B, C, E, M only)", "Onley", "Parkhurst", "Rochester", "Send", "Stoke Heath", "Swinfen Hall", "Werrington"]
    end

    it "calculates total visits" do
      subject.total_visits[prison].should == 19
    end

    it "calculates waiting visits" do
      subject.waiting_visits[prison].should == 7
    end

    it "calculates overdue visits" do
      subject.overdue_visits(1402306305)[prison].should == 4
    end

    it "calculates end-to-end time" do
      subject.end_to_end_time[prison].tap do |m|
        m.size.should == subject.total_visits[prison] - subject.waiting_visits[prison]
        m.find { |v| v < 0 }.should be_nil
      end
    end

    it "calculates processing time" do
      subject.processing_time[prison].tap do |m|
        m.size.should == subject.total_visits[prison] - subject.waiting_visits[prison]
        m.find { |v| v < 0 }.should be_nil
      end
    end

    it "calculates percentage of rejected visits without a purpose" do
      subject.percent_rejected[prison].should be_within(0.001).of(1.0/3)
    end

    it "calculates percentage of rejected visits with a purpose" do
      subject.percent_rejected(CalculatedMetrics::NO_SLOT_AVAILABLE)[prison].should be_within(0.001).of(1.0/6)
      subject.percent_rejected(CalculatedMetrics::NOT_ON_CONTACT_LIST)[prison].should be_within(0.001).of(1.0/6)
    end
  end
end
