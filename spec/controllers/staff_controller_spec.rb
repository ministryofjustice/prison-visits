require 'spec_helper'

describe StaffController do
  context "IP & key restrictions" do
    it "are enabled" do
      expect(controller).to receive(:reject_untrusted_ips!)
      get :index
    end
  end

  context "when accessing the site from the right IP address" do
    before :each do
      allow(controller).to receive(:reject_untrusted_ips!)
    end

    context "for each staff page" do
      it "renders a html view for index" do
        get :index
      end

      it "renders a html view for changes" do
        get :changes
      end

      it "renders a html view for downloads" do
        get :downloads
      end

      it "renders a html view for guide" do
        get :guide
      end

      it "renders a html view for training" do
        get :training
      end

      it "renders a html view for troubleshooting" do
        get :troubleshooting
      end

      after :each do
        expect(response).to be_success
      end
    end
  end
end
