shared_examples "a CalculatedMetrics instance" do
  it "calculates total visits" do
    subject.total_visits.should == 247
  end

  it "calculates waiting visits" do
    subject.waiting_visits.should == 4
  end

  it "calculates rejected visits" do
    subject.rejected_visits.should == 75
  end

  it "calculates confirmed visits" do
    subject.confirmed_visits.should == 167
  end

  it "calculates overdue visits" do
    subject.overdue_visits(1408379329).should == 2
  end

  it "calculates end-to-end time" do
    subject.end_to_end_time.tap do |m|
      m.find { |v| v < 0 }.should be_nil
    end
  end

  it "calculates processing time" do
    subject.processing_time.tap do |m|
      m.find { |v| v < 0 }.should be_nil
    end
  end

  it "calculates percentage of rejected visits without a purpose" do
    subject.percent_rejected.should be_within(0.001).of(0.303)
  end

  it "calculates the number of rejected visits with a particular reason" do
    subject.rejected_for_reason[Confirmation::NO_SLOT_AVAILABLE].should == 11
    subject.rejected_for_reason[Confirmation::NOT_ON_CONTACT_LIST].should == 38
    subject.rejected_for_reason[Confirmation::NO_VOS_LEFT].should == 26
  end

  it "calculates percentage of rejected visits with a purpose" do
    subject.percent_rejected(Confirmation::NO_SLOT_AVAILABLE).should be_within(0.001).of(0.044)
    subject.percent_rejected(Confirmation::NOT_ON_CONTACT_LIST).should be_within(0.001).of(0.153)
    subject.percent_rejected(Confirmation::NO_VOS_LEFT).should be_within(0.001).of(0.105)
  end
end
