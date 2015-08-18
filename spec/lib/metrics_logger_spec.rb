require 'rails_helper'
require 'metrics_logger'

RSpec.describe MetricsLogger do
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
      expect(entry.kind).to eq('deferred')
      expect(entry.visit_id).to eq(sample_visit.visit_id)
      expect(entry.requested_at).to eq(@time)
      expect(entry.nomis_id).to eq('RCI')
      expect(entry.opened_at).to be_nil
      expect(entry.processed_at).to be_nil
      expect(entry.processing_time).to be_nil
      expect(entry.end_to_end_time).to be_nil
      expect(entry.outcome).to eq('pending')
    end
  end

  it "logs when the prison staff clicks on the link, but only the first instance" do
    subject.record_visit_request(sample_visit)
    expect {
      subject.record_link_click(sample_visit)
    }.to change { VisitMetricsEntry.count }.by 0
    VisitMetricsEntry.last.tap do |entry|
      expect(entry.kind).to eq('deferred')
      expect(entry.visit_id).to eq(sample_visit.visit_id)
      expect(entry.requested_at).to eq(@time)
      expect(entry.opened_at).to eq(@time)
      expect(entry.nomis_id).to eq('RCI')
      expect(entry.processed_at).to be_nil
      expect(entry.end_to_end_time).to be_nil
      expect(entry.processing_time).to be_nil
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
      expect(entry.kind).to eq('deferred')
      expect(entry.visit_id).to eq(sample_visit.visit_id)
      expect(entry.requested_at).to eq(@time)
      expect(entry.nomis_id).to eq('RCI')
      expect(entry.processed_at).to eq(@time)
      expect(entry.outcome).to eq('confirmed')
      expect(entry.end_to_end_time).to eq(0)
      expect(entry.processing_time).to eq(0)
    end
  end

  it "logs when the visit is rejected" do
    subject.record_visit_request(sample_visit)
    subject.record_link_click(sample_visit)
    expect {
      subject.record_booking_rejection(sample_visit, 'because')
    }.to change { VisitMetricsEntry.count }.by 0
    VisitMetricsEntry.last.tap do |entry|
      expect(entry.kind).to eq('deferred')
      expect(entry.visit_id).to eq(sample_visit.visit_id)
      expect(entry.requested_at).to eq(@time)
      expect(entry.nomis_id).to eq('RCI')
      expect(entry.processed_at).to eq(@time)
      expect(entry.outcome).to eq('rejected')
      expect(entry.reason).to eq('because')
      expect(entry.end_to_end_time).to eq(0)
      expect(entry.processing_time).to eq(0)
    end
  end

  it "logs when the visit was instantly booked" do
    expect {
      subject.record_instant_visit(sample_visit)
    }.to change { VisitMetricsEntry.count }.by 1
    VisitMetricsEntry.last.tap do |entry|
      expect(entry.visit_id).to eq(sample_visit.visit_id)
      expect(entry.kind).to eq('instant')
      expect(entry.outcome).to eq('confirmed')
      expect(entry.requested_at).to eq(@time)
      expect(entry.processed_at).to eq(@time)
    end
  end

  it "responds with a visit request status as cancelled" do
    subject.record_visit_request(sample_visit)
    subject.record_link_click(sample_visit)
    subject.record_booking_cancellation(sample_visit.visit_id, 'request_cancelled')
    expect(subject.processed?(sample_visit)).to be_falsey
    expect(subject.visit_status(sample_visit.visit_id)).to eq('request_cancelled')
  end

  it "responds with a visit status as confirmed" do
    subject.record_visit_request(sample_visit)
    subject.record_link_click(sample_visit)
    subject.record_booking_confirmation(sample_visit)
    expect(subject.processed?(sample_visit)).to be_truthy
    expect(subject.visit_status(sample_visit.visit_id)).to eq('confirmed')
  end

  ['visit_cancelled', 'request_cancelled'].each do |reason|
    it "responds with a visit status as cancelled when reason is #{reason}" do
      subject.record_visit_request(sample_visit)
      subject.record_link_click(sample_visit)
      subject.record_booking_cancellation(sample_visit.visit_id, reason)
      expect(subject.processed?(sample_visit)).to be_falsey
      expect(subject.visit_status(sample_visit.visit_id)).to eq(reason)
    end
  end

  it "blows up when trying to cancel with an unknown reason" do
    expect {
      subject.record_visit_request(sample_visit)
      subject.record_link_click(sample_visit)
      subject.record_booking_cancellation(sample_visit.visit_id, 'whatever')
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "responds with a visit status as rejected" do
    subject.record_visit_request(sample_visit)
    subject.record_link_click(sample_visit)
    subject.record_booking_rejection(sample_visit, 'because')
    expect(subject.processed?(sample_visit)).to be_truthy
    expect(subject.visit_status(sample_visit.visit_id)).to eq('rejected')
  end

  it "responds with a visit status as not processed" do
    subject.record_visit_request(sample_visit)
    expect(subject.processed?(sample_visit)).to be_falsey
    expect(subject.visit_status(sample_visit.visit_id)).to eq('pending')
  end

  context "the backing store is down" do
    it "silently discards a visit request" do
      expect(VisitMetricsEntry).to receive(:create!).and_raise(e = PG::ConnectionBad.new)
      expect(Raven).to receive(:capture_exception).with(e)
      expect {
        subject.record_visit_request(sample_visit)
      }.not_to change { VisitMetricsEntry.count }
    end

    context "looking for an entry" do
      before :each do
        expect(VisitMetricsEntry).to receive(:where).and_raise(e = PG::ConnectionBad.new)
        expect(Raven).to receive(:capture_exception).with(e)
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
      expect(subject.record_link_click(sample_visit)).to be_nil
    end

    it "silently discards a booking confirmation" do
      expect(subject.record_booking_confirmation(sample_visit)).to be_nil
    end

    it "silently discards a booking rejection" do
      expect(subject.record_booking_rejection(sample_visit, 'reason')).to be_nil
    end

    it "returns status as unknown" do
      expect(subject.processed?(sample_visit)).to be_falsey
    end
  end
end
