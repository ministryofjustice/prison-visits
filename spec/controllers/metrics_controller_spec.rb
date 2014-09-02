require 'spec_helper'

describe MetricsController do
  let :mock_refresher do
    double('cache_refresher', fetch: CacheRefresher::Dataset.new(0, {}), update: CacheRefresher::Dataset.new(1, {}))
  end

  before :each do
    controller.stub(:cache_refresher).and_return(mock_refresher)
  end

  context "IP & key restrictions" do
    it "are enabled" do
      controller.should_receive(:reject_untrusted_ips_and_without_key!)
      get :index
    end
  end

  context "when accessing the site from the right IP address" do
    before :each do
      controller.stub(:reject_untrusted_ips_and_without_key!)
    end

    context "for all prisons" do
      it "renders a html view" do
        get :index
      end

      it "renders a csv view" do
        get :index, format: :csv
      end

      after :each do
        response.should be_success
      end
    end
  end
end
