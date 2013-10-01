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

  describe "step 2" do
    context "given valid visitor information" do
      let(:visitor_hash) do
        {
          visit: {
            visitor: [
              full_name: 'Sue Demin',
              date_of_birth: '1988-03-14',
              email: 'sue.denim@gmail.com',
              phone: '07783 123 456'
            ]
          },
          next: ''
        }
      end

      before :each do
        get :step1
      end

      it "updates visitor information" do
        expect {
          post :update_step2, visitor_hash
        }.to change { session[:visit].visitors[0].full_name }
      end
    end

    context "given invalid visitor information" do
      let(:visitor_hash) do
        {
          visit: {
            visitor: [
              full_name: '',
              date_of_birth: '1988-03-14',
              email: 'sue.denim@gmail.com',
              phone: '07783 123 456'
            ]
          },
          next: ''
        }
      end

      before :each do
        get :step1
      end

      it "rejects visitor information" do
        post :update_step2, visitor_hash
        response.should redirect_to(step2_path)
        session[:visit].visitors[0].should_not be_valid
      end
    end
  end

  describe "step 4 - select a timeslot" do
    before :each do
      get :step1
    end

    context "correct slot information" do
      let(:slots_hash) do
        {
          visit: {
            slots: [
                    {
                      date: '2013-01-01',
                      times: '13:45 - 20:00'
                    }
                   ]
          }
        }
      end

      it "permits us to select a time slot" do
        post :update_step4, slots_hash
        response.should redirect_to(step5_path)
      end
    end

    context "no slots" do
      let(:slots_hash) do
        {
          visit: { slots: [{}] }
        }
      end

      it "prompts us to retry" do
        post :update_step4, slots_hash
        response.should redirect_to(step4_path)
      end
    end

    context "too many slots" do
      let(:slots_hash) do
        {
          visit: { slots: [{ date: '2013-01-01', times: '12:00 - 13:00' }] * 4 }
        }
      end

      it "prompts us to retry" do
        post :update_step4, slots_hash
        response.should redirect_to(step4_path)
      end
    end
  end
end
