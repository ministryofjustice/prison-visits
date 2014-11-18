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
      entry.kind.should == 'deferred'
      entry.visit_id.should == 'ABC'
      entry.requested_at.should == @time
      entry.prison_name.should == 'Rochester'
      entry.opened_at.should be_nil
      entry.processed_at.should be_nil
      entry.processing_time.should be_nil
      entry.end_to_end_time.should be_nil
    end
  end

  it "logs when the prison staff clicks on the link, but only the first instance" do
    subject.record_visit_request(visit)
    expect {
      subject.record_link_click(visit)
    }.to change { VisitMetricsEntry.count }.by 0
    VisitMetricsEntry.last.tap do |entry|
      entry.kind.should == 'deferred'
      entry.visit_id.should == 'ABC'
      entry.requested_at.should == @time
      entry.opened_at.should == @time
      entry.prison_name.should == 'Rochester'
      entry.processed_at.should be_nil
      entry.end_to_end_time.should be_nil
      entry.processing_time.should be_nil
    end
    Timecop.return
    expect {
      subject.record_link_click(visit)
    }.not_to change { VisitMetricsEntry.last.opened_at }
  end

  it "logs when the visit is confirmed" do
    subject.record_visit_request(visit)
    subject.record_link_click(visit)
    expect {
      subject.record_booking_confirmation(visit)
    }.to change { VisitMetricsEntry.count }.by 0
    VisitMetricsEntry.last.tap do |entry|
      entry.kind.should == 'deferred'
      entry.visit_id.should == 'ABC'
      entry.requested_at.should == @time
      entry.prison_name.should == 'Rochester'
      entry.processed_at.should == @time
      entry.outcome.should == 'confirmed'
      entry.end_to_end_time.should == 0
      entry.processing_time.should == 0
    end
  end

  it "logs when the visit is rejected" do
    subject.record_visit_request(visit)
    subject.record_link_click(visit)
    expect {
      subject.record_booking_rejection(visit, 'because')
    }.to change { VisitMetricsEntry.count }.by 0
    VisitMetricsEntry.last.tap do |entry|
      entry.kind.should == 'deferred'
      entry.visit_id.should == 'ABC'
      entry.requested_at.should == @time
      entry.prison_name.should == 'Rochester'
      entry.processed_at.should == @time
      entry.outcome.should == 'rejected'
      entry.reason.should == 'because'
      entry.end_to_end_time.should == 0
      entry.processing_time.should == 0
    end
  end

  it "logs when the visit was instantly booked" do
    expect {
      subject.record_instant_visit(visit)
    }.to change { VisitMetricsEntry.count }.by 1
    VisitMetricsEntry.last.tap do |entry|
      entry.visit_id.should == 'ABC'
      entry.kind.should == 'instant'
      entry.requested_at.should == @time
      entry.processed_at.should == @time
    end
  end

  it "responds with a visit status as confirmed" do
    subject.record_visit_request(visit)
    subject.record_link_click(visit)
    subject.record_booking_confirmation(visit)
    subject.processed?(visit).should be_true
    subject.visit_status(visit.visit_id).should == :confirmed
  end

  it "responds with a visit status as rejected" do
    subject.record_visit_request(visit)
    subject.record_link_click(visit)
    subject.record_booking_rejection(visit, 'because')
    subject.processed?(visit).should be_true
    subject.visit_status(visit.visit_id).should == :rejected
  end

  it "responds with a visit status as not processed" do
    subject.record_visit_request(visit)
    subject.processed?(visit).should be_false
    subject.visit_status(visit.visit_id).should == :pending
  end

  context "the backing store is down" do
    it "silently discards a visit request" do
      VisitMetricsEntry.should_receive(:create!).and_raise(e = PG::ConnectionBad.new)
      Raven.should_receive(:capture_exception).with(e)
      expect {
        subject.record_visit_request(visit)
      }.not_to change { VisitMetricsEntry.count }
    end

    context "looking for an entry" do
      before :each do
        VisitMetricsEntry.should_receive(:where).and_raise(e = PG::ConnectionBad.new)
        Raven.should_receive(:capture_exception).with(e)
      end
      
      it "silently discards a link click" do
        subject.record_link_click(visit)
      end
      
      it "silently discards a booking confirmation" do
        subject.record_booking_confirmation(visit)
      end
      
      it "silently discards a booking rejection" do
        subject.record_booking_rejection(visit, 'reason')
      end

      it "returns unknown as status" do
        subject.processed?(visit)
      end
    end
  end

  context "data is inconsistent following an outage in the backing store" do
    it "silently discards a link click" do
      subject.record_link_click(visit).should be_nil
    end
      
    it "silently discards a booking confirmation" do
      subject.record_booking_confirmation(visit).should be_nil
    end
    
    it "silently discards a booking rejection" do
      subject.record_booking_rejection(visit, 'reason').should be_nil
    end

    it "returns status as unknown" do
      subject.processed?(visit).should be_false
    end
  end
end
