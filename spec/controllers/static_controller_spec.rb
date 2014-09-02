require 'spec_helper'

describe StaticController do
  context "CSV" do
    before :each do
      get :prison_emails, format: :csv
      response.should be_success
      @lines = response.body.split(/\n/)
    end

    it "doesn't contain duplicate entries" do
      @lines.uniq.should == @lines
    end
  end
end
