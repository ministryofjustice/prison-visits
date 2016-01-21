require 'rails_helper'

RSpec.describe StartPageController, type: :controller do
  describe 'show' do
    let :configured_probability do
      StartPageController::NEW_APP_PROBABILITY_DEFAULT
    end

    it 'stores a random threshold in the user\'s session' do
      get :show
      expect(session[:app_choice_threshold]).to be_in(0..1)
    end

    it "redirects to the new app if the user's threshold is low" do
      session[:app_choice_threshold] = rand(0..configured_probability)
      get :show
      expect(response).to redirect_to('/en/request')
    end

    it "redirects to this (old) app if the user's threshold is high" do
      session[:app_choice_threshold] = rand(configured_probability..1)
      get :show
      expect(response).to redirect_to('/prisoner')
    end
  end
end
