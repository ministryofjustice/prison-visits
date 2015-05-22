shared_examples "a CalculatedMetrics instance" do
  it "calculates total visits" do
    expect(subject.total_visits).to eq(247)
  end

  it "calculates waiting visits" do
    expect(subject.waiting_visits).to eq(4)
  end

  it "calculates rejected visits" do
    expect(subject.rejected_visits).to eq(75)
  end

  it "calculates confirmed visits" do
    expect(subject.confirmed_visits).to eq(167)
  end

  it "calculates overdue visits" do
    expect(subject.overdue_visits(1408379329)).to eq(2)
  end

  it "calculates end-to-end time" do
    subject.end_to_end_time.tap do |m|
      expect(m.find { |v| v < 0 }).to be_nil
    end
  end

  it "calculates processing time" do
    subject.processing_time.tap do |m|
      expect(m.find { |v| v < 0 }).to be_nil
    end
  end

  it "calculates percentage of rejected visits without a purpose" do
    expect(subject.percent_rejected).to be_within(0.001).of(0.303)
  end

  it "calculates the number of rejected visits with a particular reason" do
    expect(subject.rejected_for_reason[Confirmation::NO_SLOT_AVAILABLE]).to eq(11)
    expect(subject.rejected_for_reason[Confirmation::NOT_ON_CONTACT_LIST]).to eq(38)
    expect(subject.rejected_for_reason[Confirmation::NO_VOS_LEFT]).to eq(26)
  end

  it "calculates percentage of rejected visits with a purpose" do
    expect(subject.percent_rejected(Confirmation::NO_SLOT_AVAILABLE)).to be_within(0.001).of(0.044)
    expect(subject.percent_rejected(Confirmation::NOT_ON_CONTACT_LIST)).to be_within(0.001).of(0.153)
    expect(subject.percent_rejected(Confirmation::NO_VOS_LEFT)).to be_within(0.001).of(0.105)
  end
end
