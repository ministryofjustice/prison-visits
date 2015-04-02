require 'spec_helper'
require 'metrics_logger'

describe MetricsLogger do
  before :each do
    Timecop.freeze(@time = Time.utc(2013, 12, 12, 0, 0, 0))
  end

  after :each do
    Timecop.return
  end

  it "logs a visit request" do
    expect {
      subject.record_visit_request(sample_visit)
    }.to change { VisitMetricsEntry.count }.by 1
    VisitMetricsEntry.last.tap do |entry|
      entry.kind.should == 'deferred'
      entry.visit_id.should == sample_visit.visit_id
      entry.requested_at.should == @time
      entry.nomis_id.should == 'RCI'
      entry.opened_at.should be_nil
      entry.processed_at.should be_nil
      entry.processing_time.should be_nil
      entry.end_to_end_time.should be_nil
    end
  end

  it "logs when the prison staff clicks on the link, but only the first instance" do
    subject.record_visit_request(sample_visit)
    expect {
      subject.record_link_click(sample_visit)
    }.to change { VisitMetricsEntry.count }.by 0
    VisitMetricsEntry.last.tap do |entry|
      entry.kind.should == 'deferred'
      entry.visit_id.should == sample_visit.visit_id
      entry.requested_at.should == @time
      entry.opened_at.should == @time
      entry.nomis_id.should == 'RCI'
      entry.processed_at.should be_nil
      entry.end_to_end_time.should be_nil
      entry.processing_time.should be_nil
    end
    Timecop.return
    expect {
      subject.record_link_click(sample_visit)
    }.not_to change { VisitMetricsEntry.last.opened_at }
  end

  it "logs when the visit is confirmed" do
    subject.record_visit_request(sample_visit)
    subject.record_link_click(sample_visit)
    expect {
      subject.record_booking_confirmation(sample_visit)
    }.to change { VisitMetricsEntry.count }.by 0
    VisitMetricsEntry.last.tap do |entry|
      entry.kind.should == 'deferred'
      entry.visit_id.should == sample_visit.visit_id
      entry.requested_at.should == @time
      entry.nomis_id.should == 'RCI'
      entry.processed_at.should == @time
      entry.outcome.should == 'confirmed'
      entry.end_to_end_time.should == 0
      entry.processing_time.should == 0
    end
  end

  it "logs when the visit is rejected" do
    subject.record_visit_request(sample_visit)
    subject.record_link_click(sample_visit)
    expect {
      subject.record_booking_rejection(sample_visit, 'because')
    }.to change { VisitMetricsEntry.count }.by 0
    VisitMetricsEntry.last.tap do |entry|
      entry.kind.should == 'deferred'
      entry.visit_id.should == sample_visit.visit_id
      entry.requested_at.should == @time
      entry.nomis_id.should == 'RCI'
      entry.processed_at.should == @time
      entry.outcome.should == 'rejected'
      entry.reason.should == 'because'
      entry.end_to_end_time.should == 0
      entry.processing_time.should == 0
    end
  end

  it "logs when the visit was instantly booked" do
    expect {
      subject.record_instant_visit(sample_visit)
    }.to change { VisitMetricsEntry.count }.by 1
    VisitMetricsEntry.last.tap do |entry|
      entry.visit_id.should == sample_visit.visit_id
      entry.kind.should == 'instant'
      entry.requested_at.should == @time
      entry.processed_at.should == @time
    end
  end

  it "responds with a visit request status as cancelled" do
    subject.record_visit_request(sample_visit)
    subject.record_link_click(sample_visit)
    subject.record_booking_cancellation(sample_visit.visit_id, :request_cancelled)
    subject.processed?(sample_visit).should be_false
    subject.visit_status(sample_visit.visit_id).should == :request_cancelled
  end

  it "responds with a visit status as confirmed" do
    subject.record_visit_request(sample_visit)
    subject.record_link_click(sample_visit)
    subject.record_booking_confirmation(sample_visit)
    subject.processed?(sample_visit).should be_true
    subject.visit_status(sample_visit.visit_id).should == :confirmed
  end

  it "responds with a visit status as cancelled" do
    subject.record_visit_request(sample_visit)
    subject.record_link_click(sample_visit)
    subject.record_booking_cancellation(sample_visit.visit_id, :visit_cancelled)
    subject.processed?(sample_visit).should be_false
    subject.visit_status(sample_visit.visit_id).should == :visit_cancelled
  end

  it "responds with a visit status as rejected" do
    subject.record_visit_request(sample_visit)
    subject.record_link_click(sample_visit)
    subject.record_booking_rejection(sample_visit, 'because')
    subject.processed?(sample_visit).should be_true
    subject.visit_status(sample_visit.visit_id).should == :rejected
  end

  it "responds with a visit status as not processed" do
    subject.record_visit_request(sample_visit)
    subject.processed?(sample_visit).should be_false
    subject.visit_status(sample_visit.visit_id).should == :pending
  end

  context "the backing store is down" do
    it "silently discards a visit request" do
      VisitMetricsEntry.should_receive(:create!).and_raise(e = PG::ConnectionBad.new)
      Raven.should_receive(:capture_exception).with(e)
      expect {
        subject.record_visit_request(sample_visit)
      }.not_to change { VisitMetricsEntry.count }
    end

    context "looking for an entry" do
      before :each do
        VisitMetricsEntry.should_receive(:where).and_raise(e = PG::ConnectionBad.new)
        Raven.should_receive(:capture_exception).with(e)
      end
      
      it "silently discards a link click" do
        subject.record_link_click(sample_visit)
      end
      
      it "silently discards a booking confirmation" do
        subject.record_booking_confirmation(sample_visit)
      end
      
      it "silently discards a booking rejection" do
        subject.record_booking_rejection(sample_visit, 'reason')
      end

      it "returns unknown as status" do
        subject.processed?(sample_visit)
      end
    end
  end

  context "data is inconsistent following an outage in the backing store" do
    it "silently discards a link click" do
      subject.record_link_click(sample_visit).should be_nil
    end
      
    it "silently discards a booking confirmation" do
      subject.record_booking_confirmation(sample_visit).should be_nil
    end
    
    it "silently discards a booking rejection" do
      subject.record_booking_rejection(sample_visit, 'reason').should be_nil
    end

    it "returns status as unknown" do
      subject.processed?(sample_visit).should be_false
    end
  end
end
