require 'spec_helper'

describe ApplicationController do
  context "when IP restriction hook is enabled" do
    controller do
      def index
        render text: 'OK'
      end
    end

    before :each do
      controller.class.permit_only_from_prisons
    end

    it "rejects untrusted IPs" do
      Rails.configuration.permitted_ips_for_confirmations.stub(:include?).and_return(false)
      expect {
        get :index
      }.to raise_error(ActionController::RoutingError, 'Go away')
    end

    it "accepts trusted IPs" do
      Rails.configuration.permitted_ips_for_confirmations.stub(:include?).and_return(true)
      get :index
    end
  end

  context "when IP restriction hook is disabled" do
    controller do
      def index
        render text: 'OK'
      end
    end

    it "accepts all IPs" do
      controller.should_receive(:reject_untrusted_ips!).never
      get :index
    end
  end
end
