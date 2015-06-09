require 'rails_helper'

RSpec.describe StaticController, type: :controller do
  context "CSV" do
    before :each do
      get :prison_emails, format: :csv
      expect(response).to be_success
      @lines = response.body.split(/\n/)
    end

    it "doesn't contain duplicate entries" do
      expect(@lines.uniq).to eq(@lines)
    end
  end
end
