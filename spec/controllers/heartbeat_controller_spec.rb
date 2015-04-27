require 'spec_helper'

describe HeartbeatController do
  render_views
  
  context "key restrictions" do
    context "are enabled" do
      it "raises an error" do
        Rails.configuration.metrics_auth_key = ""
        controller.should_receive(:reject!)
        get :healthcheck
      end
    end
        
    context "are disabled" do
      before :each do
        controller.stub(:reject_without_key!)
      end

      it "talks to sendgrid and messagelabs" do
        PrisonMailer.should_receive(:smtp_settings).and_return(address: host = double, port: port = double)
        SendgridHelper.should_receive(:smtp_alive?).with(host, port).once
        VisitorMailer.should_receive(:smtp_settings).and_return(address: host = double, port: port = double)
        SendgridHelper.should_receive(:smtp_alive?).with(host, port).once
        get :healthcheck
      end
    end
  end
end
