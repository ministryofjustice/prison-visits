require 'spec_helper'

describe MetricsController do
  before :each do
    controller.stub(:elastic_client).and_return(double(search: []))
  end

  context "IP restrictions" do
    it "denies all other requests" do
      controller.stub(:reject_untrusted_ips!).and_raise(ActionController::RoutingError.new("Not found"))
      expect {
        get :index
      }.to raise_error(ActionController::RoutingError)
    end
  end

  context "when accessing the site from the right IP address" do
    before :each do
      controller.stub(:reject_untrusted_ips!)
    end

    context "for all prisons" do
      it "renders a html view" do
        get :index
      end

      it "renders a json view" do
        get :index, format: :json
        JSON.parse(response.body)
      end

      after :each do
        response.should be_success
      end
    end

    context "for a single prison" do
      it "renders a html view" do
        get :index, prison: 'Rochester'
        response.should be_success
      end

      it "renders a json view" do
        get :index, prison: 'Rochester', format: :json
        response.should be_success
        JSON.parse(response.body)
      end

      it "escapes the prison name" do
        controller.elastic_client.should_receive(:search).with(index: :pvb, q: 'prison:\+\-\&\&\|\|\!\(\)\{\}\[\]\^\"\~\*\?\:\\\\', size: 10_000, sort: 'timestamp:desc').once
        get :index, prison: '+-&&||!(){}[]^"~*?:\\'
      end
    end
  end
end
