require 'spec_helper'

describe HeartbeatController do
  render_views

  let :xml_body do
    Nokogiri::XML.parse(response.body)
  end

  it "says that everything is A-ok" do
    VisitMetricsEntry.create!(visit_id: SecureRandom.uuid, nomis_id: 'RCI', kind: 'deferred', requested_at: Time.now)
    get :pingdom
    response.should be_success
    xml_body.xpath('/pingdom_http_custom_check/status').text.should == "OK"
    xml_body.xpath('/pingdom_http_custom_check/response_time').text.to_f.should > 0
  end

  it "blows up" do
    expect {
      get :pingdom.id
    }.to raise_error(StandardError)
  end
end
