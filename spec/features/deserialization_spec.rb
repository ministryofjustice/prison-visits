require 'rails_helper'

RSpec.feature "deserialization" do
  include ActiveJobHelper
  include RackTestFeaturesHelper

  before do
    Timecop.travel Time.new(2015, 9, 1, 15, 47).utc
    Capybara.current_driver = :rack_test
    VisitMetricsEntry.delete_all
  end

  after do
    Timecop.return
  end

  let(:data) {
    path = File.expand_path('../../fixtures/deserialization_data.yml', __FILE__)
    YAML.load(File.read(path))
  }

  context 'before removing deferred namespace' do
    let(:data) {
      super().fetch('before_removing_deferred_namespace')
    }

    before do
      data.fetch('visit_metrics_entries').each do |hash|
        VisitMetricsEntry.create! hash
      end
      allow_any_instance_of(ApplicationController).
        to receive(:reject_untrusted_ips!)
    end

    scenario 'booking receipt' do
      link = data.fetch('booking_receipt_path')
      visit link
      expect(status).to eq(200)
      expect(page).to have_text('Your visit is not booked yet')
    end

    scenario 'booking request email' do
      link = data.fetch('booking_request_path')
      visit link
      expect(status).to eq(200)
      expect(page).to have_text('Process a visit request')
      expect(page).to have_text('Prisoner: Arthur Raffles')
      expect(page).to have_text('Visitor 1: Harry Manders')
      expect(page).to have_text('First choice: Saturday, 05/09/2015 from 09:45 - 11:15')
    end

    scenario 'booking confirmation' do
      link = data.fetch('booking_confirmation_path')
      visit link
      expect(status).to eq(200)
      expect(page).to have_text('Your visit has been confirmed')
    end
  end
end
