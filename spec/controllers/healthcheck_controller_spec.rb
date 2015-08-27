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

  let(:healthcheck) {
    double(
      Healthcheck,
      ok?: true,
      checks: {
        database: true,
        mailers: true,
        zendesk: true
      },
      queues: {
        mailers: { oldest: nil, count: 0 },
        zendesk: { oldest: nil, count: 0 }
      }
    )
  }

  before do
    allow(Healthcheck).to receive(:new).and_return(healthcheck)
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

    it 'reports services as OK' do
      expect(parsed_body).to include(
        'checks' => {
          'mailers' => true,
          'database' => true,
          'zendesk' => true
        }
      )
    end
  end

  context 'when the healthcheck is not OK' do
    before do
      allow(healthcheck).to receive(:ok?).and_return(false)
      get :index, key: key
    end

    it 'returns an HTTP Bad Gateway status' do
      expect(response).to have_http_status(:bad_gateway)
    end
  end

  context 'when there are no queue items' do
    before do
      get :index, key: key
    end

    it 'reports empty queue statuses' do
      expect(parsed_body).to include(
        'queues' => {
          'mailers' => { 'oldest' => nil, 'count' => 0 },
          'zendesk' => { 'oldest' => nil, 'count' => 0 }
        }
      )
    end
  end

  context 'when there are queue items' do
    let(:mq_created_at) { Time.at(1440685647).utc }
    let(:zq_created_at) { Time.at(1440685724).utc }

    before do
      allow(healthcheck).to receive(:queues).and_return(
        mailers: { oldest: mq_created_at, count: 1 },
        zendesk: { oldest: zq_created_at, count: 2 }
      )
      get :index, key: key
    end

    it 'reports empty queue statuses' do
      expect(parsed_body).to include(
        'queues' => {
          'mailers' => {
            'oldest' => '2015-08-27T14:27:27.000Z',
            'count' => 1
          },
          'zendesk' => {
            'oldest' => '2015-08-27T14:28:44.000Z',
            'count' => 2
          }
        }
      )
    end
  end
end
