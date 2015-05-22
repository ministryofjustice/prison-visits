require 'rails_helper'

RSpec.describe GeckoboardController, type: :controller do
  context "IP & key restrictions" do
    it "are enabled" do
      expect(controller).to receive(:reject_untrusted_ips_and_without_key!)
      get :leaderboard
    end
  end
end
