require 'rails_helper'

RSpec.describe GeckoboardController, type: :controller do
  context "IP & key restrictions" do
    it "are enabled" do
      expect(controller).to receive(:reject_without_key_or_trusted_ip!)
      get :leaderboard
    end
  end
end
