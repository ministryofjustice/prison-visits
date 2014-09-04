require 'spec_helper'
require 'metrics_logger'

describe MetricsLogger do
  let :subject do
     MetricsLogger.new(@client)
  end

  let :visit do
    sample_visit
  end

  let :visit_id do
    SecureRandom.hex
  end

  before :each do
    Timecop.freeze(time = Time.utc(2013, 12, 12, 0, 0, 0))
    (@timestamp = time.to_i).should == 1386806400
    @client = double
  end

  after :each do
    Timecop.return
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
    subject.should_receive(:visit_status).with(visit.visit_id).and_return(:confirmed)
    subject.processed?(visit).should be_true
  end

  
  it "responds with a visit status as confirmed" do
    @client.should_receive(:search).
      with(index: MetricsLogger::INDEX_NAME, q: "visit_id:#{visit_id}").
      and_return({'hits' => {
                     'total' => 1,
                     'hits' => [{
                                  "_index" => "pvb",
                                  "_type" => "metric",
                                  "_id" => "lYVH1f77Q16W4Ymf1p8bBQ",
                                  "_score" => 1,
                                  "_source" => {
                                    "visit_id" => visit_id,
                                    "timestamp" => 1406045814,
                                    "prison" => "Cardiff",
                                    "label0" => "result_confirmed"
                                  }
                                }]}})
    subject.visit_status(visit_id).should == :confirmed
  end

  it "responds with a visit status as rejected" do
    @client.should_receive(:search).
      with(index: MetricsLogger::INDEX_NAME, q: "visit_id:#{visit_id}").
      and_return({'hits' => {
                     'total' => 1,
                     'hits' => [{
                                  "_index" => "pvb",
                                  "_type" => "metric",
                                  "_id" => "lYVH1f77Q16W4Ymf1p8bBQ",
                                  "_score" => 1,
                                  "_source" => {
                                    "visit_id" => visit_id,
                                    "timestamp" => 1406045814,
                                    "prison" => "Cardiff",
                                    "label0" => "result_rejected"
                                  }
                                }]}})
    subject.visit_status(visit_id).should == :rejected
  end

  it "responds with a visit status as not processed" do
    @client.should_receive(:search).
      with(index: MetricsLogger::INDEX_NAME, q: "visit_id:#{visit_id}").
      and_return({'hits' => {
                     'total' => 1,
                     'hits' => [{
                                  "_index" => "pvb",
                                  "_type" => "metric",
                                  "_id" => "lYVH1f77Q16W4Ymf1p8bBQ",
                                  "_score" => 1,
                                  "_source" => {
                                    "visit_id" => visit_id,
                                    "timestamp" => 1406045814,
                                    "prison" => "Cardiff",
                                    "label0" => "opened_link"
                                  }
                                }]}})
   subject.visit_status(visit_id).should == :pending
  end
end
