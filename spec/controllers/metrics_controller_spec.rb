require 'rails_helper'

RSpec.describe MetricsController, type: :controller do
  context "IP & key restrictions" do
    it "are enabled" do
      expect(controller).to receive(:reject_untrusted_ips_and_without_key!)
      get :index
    end
  end

  context "when accessing the site from the right IP address" do
    before :each do
      allow(controller).to receive(:reject_untrusted_ips_and_without_key!)
    end

    context "for all prisons" do
      it "renders a html view" do
        get :index
      end

      it "renders a csv view" do
        expect_any_instance_of(CSVFormatter).to receive(:generate).once
        get :index, format: :csv
      end

      after :each do
        expect(response).to be_success
      end
    end
  end
end
