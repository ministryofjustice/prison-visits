require 'rails_helper'

RSpec.describe HealthcheckController, type: :controller do
  render_views

  let(:key) { 'super secret' }

  around do |example|
    original = Rails.configuration.metrics_auth_key
    Rails.configuration.metrics_auth_key = key
    example.call
    Rails.configuration.metrics_auth_key = original
  end

  let(:parsed_body) {
    JSON.parse(response.body)
  }

  let(:message_labs_address) { double }
  let(:message_labs_port) { double }
  let(:sendgrid_address) { double }
  let(:sendgrid_port) { double }

  before do
    allow(SendgridApi).to receive(:smtp_alive?).and_return(true)
    allow(ZENDESK_CLIENT).to receive(:tickets).and_return(double(count: 0))
  end

  shared_examples 'a service is broken' do |service|
    before do
      get :index, key: key
    end

    it 'returns an HTTP Bad Gateway status' do
      expect(response).to have_http_status(:bad_gateway)
    end

    it "reports #{service} as inaccessible" do
      expect(parsed_body).to include('checks' => include(service => false))
    end
  end

  context 'with an invalid key' do
    it 'rejects unauthenticated access' do
      expect {
        get :index, key: 'garbage'
      }.to raise_exception(ActionController::RoutingError)
    end
  end

  context 'when everything is OK' do
    before do
      get :index, key: key
    end

    it 'returns an HTTP Success status' do
      expect(response).to be_success
    end

    it 'reports sendgrid as OK' do
      expect(parsed_body).to include('checks' => include('sendgrid' => true))
    end

    it 'reports messagelabs as OK' do
      expect(parsed_body).to include('checks' => include('messagelabs' => true))
    end

    it 'reports database as OK' do
      expect(parsed_body).to include('checks' => include('database' => true))
    end

    it 'reports zendesk as OK' do
      expect(parsed_body).to include('checks' => include('zendesk' => true))
    end
  end

  context 'when messagelabs is down' do
    before do
      address = double
      port = double
      allow(PrisonMailer).
        to receive(:smtp_settings).
        and_return(address: address, port: port)
      allow(SendgridApi).
        to receive(:smtp_alive?).
        with(address, port).
        and_return(false)
    end

    it_behaves_like 'a service is broken', 'messagelabs'
  end

  context 'when sendgrid is down' do
    before do
      address = double
      port = double
      allow(VisitorMailer).
        to receive(:smtp_settings).
        and_return(address: address, port: port)
      allow(SendgridApi).
        to receive(:smtp_alive?).
        with(address, port).
        and_return(false)
    end

    it_behaves_like 'a service is broken', 'sendgrid'
  end

  context 'when the database is down' do
    before do
      allow(ActiveRecord::Base.connection).
        to receive(:active?).
        and_return(false)
    end

    it_behaves_like 'a service is broken', 'database'
  end

  context 'when the database is off' do
    before do
      allow(ActiveRecord::Base.connection).
        to receive(:active?).
        and_raise(PG::ConnectionBad)
    end

    it_behaves_like 'a service is broken', 'database'
  end

  context 'when Zendesk is inaccessible' do
    before do
      allow(ZENDESK_CLIENT).to receive(:tickets).and_return(double(count: -1))
    end

    it_behaves_like 'a service is broken', 'zendesk'
  end
end
