require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  context "always" do
    controller do
      def index
        render text: 'OK'
      end
    end

    it "sets additional metadata for sentry" do
      @request = ActionController::TestRequest.new
      session[:visit] = Visit.new(prisoner: Prisoner.new(prison_name: 'Rochester'), visit_id: 'visit-id')
      allow(controller).to receive(:request_id).and_return('request_id')
      get :index
      expect(Raven.extra_context).to eq({request_id: 'request_id', visit_id: 'visit-id', prison: 'Rochester'})
      expect(response['X-Request-Id']).to eq('request_id')
    end

    it "sets additional metadata for logstasher" do
      visit_id = "LOL"
      expect(LogStasher.request_context).to receive(:[]=).with(:visit_id, visit_id)
      expect(LogStasher.custom_fields).to receive(:<<).with(:visit_id)
      controller.logstasher_add_visit_id(visit_id)
    end
  end

  context "when IP & key restriction is enabled" do
    controller do
      def index
        render text: 'OK'
      end
    end

    before :each do
      allow(Rails.configuration).to receive(:trusted_users_access_key).and_return('lulz')
      controller.class.permit_only_trusted_users
    end

    it "rejects untrusted IPs" do
      allow(Rails.configuration.permitted_ips_for_confirmations).to receive(:include?).and_return(false)
      expect {
        get :index
      }.to raise_error(ActionController::RoutingError)
    end

    it "accepts trusted IPs" do
      allow(Rails.configuration.permitted_ips_for_confirmations).to receive(:include?).and_return(true)
      get :index
    end

    it "accepts clients with a key" do
      get :index, key: 'lulz'
    end
  end

  context "when IP restriction hook is enabled" do
    controller do
      def index
        render text: 'OK'
      end
    end

    before :each do
      controller.class.permit_only_trusted_users
    end

    it "rejects untrusted IPs" do
      allow(Rails.configuration.permitted_ips_for_confirmations).to receive(:include?).and_return(false)
      expect {
        get :index
      }.to raise_error(ActionController::RoutingError)
    end

    it "accepts trusted IPs" do
      allow(Rails.configuration.permitted_ips_for_confirmations).to receive(:include?).and_return(true)
      get :index
    end
  end

  context "when key restriction is enabled" do
    controller do
      def index
        render text: 'OK'
      end
    end

    before :each do
      controller.class.permit_only_trusted_users
      Rails.configuration.trusted_users_access_key = "VALID"
    end

    it "accepts clients with key" do
      get :index, key: "VALID"
      expect(response).to be_success
    end

    it "rejects clients without key" do
      expect{
        get :index, key: "INVALID"
      }.to raise_error(ActionController::RoutingError)
    end
  end

  context "when IP restriction hook is disabled" do
    controller do
      def index
        render text: 'OK'
      end
    end

    it "accepts all IPs" do
      expect(controller).to receive(:reject_without_key_or_trusted_ip!).never
      get :index
    end
  end
end
