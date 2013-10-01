require 'spec_helper'

describe VisitController do
  render_views

  describe "step 1 - enter prisoner's details" do
    it "renders the form for entering prisoner details, and assigns the session" do
      expect {
        get :step1
        response.should be_success
      }.to change { session[:visit] }
    end

    context "given valid prisoner details" do
      let(:prisoner_hash) do
        {
          prisoner: {
            full_name: 'Jimmy Fingers',
            date_of_birth: '1986-04-20',
            number: '31337',
            prison_name: 'Gartree'
          }
        }
      end

      before :each do
        get :step1
      end

      it "updates prisoner details" do
        post :update_step1, prisoner_hash
        response.should redirect_to(step2_path)
      end
    end

    context "given invalid prisoner details" do
      let(:prisoner_hash) do
        {
          prisoner: {
            full_name: '',
            date_of_birth: '1986-04-20',
            number: '31337',
            prison_name: 'Gartree'
          }
        }
      end

      before :each do
        get :step1
      end

      it "doesn't update prisoner details" do
        post :update_step1, prisoner_hash
        response.should redirect_to(step1_path)
      end
    end
  end
end
