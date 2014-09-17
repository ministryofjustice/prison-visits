require 'spec_helper'
require 'metrics_logger'

describe MetricsLogger do
  let :visit do
    sample_visit
  end

  before :each do
    Timecop.freeze(@time = Time.utc(2013, 12, 12, 0, 0, 0))
  end

  after :each do
    Timecop.return
  end

  it "logs a visit request" do
    expect {
      subject.record_visit_request(visit)
    }.to change { VisitMetricsEntry.count }.by 1
    VisitMetricsEntry.last.tap do |entry|
      entry.visit_id.should == 'ABC'
      entry.requested_at.should == @time
      entry.prison_name.should == 'Rochester'
      entry.opened_at.should be_nil
      entry.processed_at.should be_nil
    end
  end

  it "logs when the prison staff clicks on the link" do
    subject.record_visit_request(visit)
    expect {
      subject.record_link_click(visit)
    }.to change { VisitMetricsEntry.count }.by 0
    VisitMetricsEntry.last.tap do |entry|
      entry.visit_id.should == 'ABC'
      entry.requested_at.should == @time
      entry.prison_name.should == 'Rochester'
      entry.processed_at.should be_nil
    end
  end

  it "logs when the visit is confirmed" do
    subject.record_visit_request(visit)
    expect {
      subject.record_booking_confirmation(visit)
    }.to change { VisitMetricsEntry.count }.by 0
    VisitMetricsEntry.last.tap do |entry|
      entry.visit_id.should == 'ABC'
      entry.requested_at.should == @time
      entry.prison_name.should == 'Rochester'
      entry.processed_at.should == @time
      entry.outcome.should == 'confirmed'
    end
  end

  it "logs when the visit is rejected" do
    subject.record_visit_request(visit)
    expect {
      subject.record_booking_rejection(visit, 'because')
    }.to change { VisitMetricsEntry.count }.by 0
    VisitMetricsEntry.last.tap do |entry|
      entry.visit_id.should == 'ABC'
      entry.requested_at.should == @time
      entry.prison_name.should == 'Rochester'
      entry.processed_at.should == @time
      entry.outcome.should == 'rejected'
      entry.reason.should == 'because'
    end
  end

  it "responds with a visit status as confirmed" do
    subject.record_visit_request(visit)
    subject.record_booking_confirmation(visit)
    subject.processed?(visit).should be_true
    subject.visit_status(visit.visit_id).should == :confirmed
  end

  it "responds with a visit status as rejected" do
    subject.record_visit_request(visit)
    subject.record_booking_rejection(visit, 'because')
    subject.processed?(visit).should be_true
    subject.visit_status(visit.visit_id).should == :rejected
  end

  it "responds with a visit status as not processed" do
    subject.record_visit_request(visit)
    subject.processed?(visit).should be_false
    subject.visit_status(visit.visit_id).should == :pending
  end
end
