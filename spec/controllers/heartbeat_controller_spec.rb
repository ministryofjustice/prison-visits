require 'spec_helper'

describe HeartbeatController do
  render_views

  context "with key restrictions" do
    context "enabled" do
      it "raises an error" do
        Rails.configuration.metrics_auth_key = ""
        controller.should_receive(:reject!)
        get :healthcheck
      end
    end

    context "disabled" do
      before :each do
        controller.stub(:reject_without_key!)
      end

      it "talks to sendgrid and messagelabs" do
        PrisonMailer.should_receive(:smtp_settings).and_return(address: host = double, port: port = double)
        SendgridHelper.should_receive(:smtp_alive?).with(host, port).once.and_return(true)
        VisitorMailer.should_receive(:smtp_settings).and_return(address: host = double, port: port = double)
        SendgridHelper.should_receive(:smtp_alive?).with(host, port).once.and_return(true)
        get :healthcheck

        assert_response(:success, response.status)
        parsed_body = JSON.parse(response.body)
        parsed_body['checks']['messagelabs'].should be_true
        parsed_body['checks']['sendgrid'].should be_true
        parsed_body['checks']['database'].should be_true
      end
    end
  end
end
