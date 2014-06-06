require 'spec_helper'
require 'metrics_logger'

describe MetricsLogger do
  let :subject do
     MetricsLogger.new(@client)
  end

  let :visit do
    sample_visit
  end

  before :each do
    Timecop.freeze(time = Time.utc(2013, 12, 12, 0, 0, 0))
    (@timestamp = time.to_i).should == 1386806400
    @client = double
  end

  it "logs a visit request" do
    subject.should_receive(:<<).with(body: {visit_id: "ABC", timestamp: 1386806400, prison: "Rochester", label0: :visit_request})
    subject.record_visit_request(visit)
  end

  it "logs when the prison staff clicks on the link" do
    subject.should_receive(:<<).with(body: {visit_id: "ABC", timestamp: 1386806400, prison: "Rochester", label0: :opened_link})
    subject.record_link_click(visit)
  end

  it "logs when the visit is confirmed" do
    subject.should_receive(:<<).with(body: {visit_id: "ABC", timestamp: 1386806400, prison: "Rochester", label0: :result_confirmed})
    subject.record_booking_confirmation(visit)
  end

  it "logs when the visit is rejected" do
    subject.should_receive(:<<).with(body: {visit_id: "ABC", timestamp: 1386806400, prison: "Rochester", label0: :result_rejected, label1: 'because'})
    subject.record_booking_rejection(visit, 'because')
  end

  it "responds to a visit being processed or not" do
    @client.should_receive(:search).
      with(index: MetricsLogger::INDEX_NAME, search_type: :count,
           body: { query: { bool: { must: [{term: {visit_id: visit.visit_id}}, {prefix: {label0: "result_"}}]}}}).
      and_return({'hits' => {'total' => 1}})
    subject.processed?(visit).should be_true
  end
end
