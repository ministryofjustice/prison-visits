require 'spec_helper'

describe VisitController do
  render_views

  describe "step 1 - enter prisoner's details" do
    it "renders the form for entering prisoner details, and assigns the session" do
      expect {
        get :prisoner_details
        response.should be_success
      }.to change { session[:visit] }
    end

    context "given valid prisoner details" do
      let(:prisoner_hash) do
        {
          prisoner: {
            first_name: 'Jimmy',
            last_name: 'Fingers',
            date_of_birth: '1986-04-20',
            number: 'g3133ff',
            prison_name: 'Gartree'
          }
        }
      end

      before :each do
        get :prisoner_details
      end

      it "updates prisoner details" do
        post :update_prisoner_details, prisoner_hash
        response.should redirect_to(visitor_details_path)
      end
    end

    context "given invalid prisoner details" do
      let(:prisoner_hash) do
        {
          prisoner: {
            first_name: '',
            last_name: '',
            date_of_birth: '1986-04-20',
            number: '31337',
            prison_name: 'Gartree'
          }
        }
      end

      before :each do
        get :prisoner_details
      end

      it "doesn't update prisoner details" do
        post :update_prisoner_details, prisoner_hash
        response.should redirect_to(prisoner_details_path)
      end
    end
  end

  describe "step 2" do
    context "given valid visitor information" do
      let(:visitor_hash) do
        {
          visit: {
            visitor: [
              first_name: 'Sue',
              last_name: 'Demin',
              date_of_birth: '1988-03-14',
              email: 'sue.denim@gmail.com',
              phone: '07783 123 456'
            ]
          },
          next: ''
        }
      end

      before :each do
        get :prisoner_details
      end

      it "updates visitor information" do
        expect {
          post :update_visitor_details, visitor_hash
        }.to change { session[:visit].visitors[0].first_name }
      end
    end

    context "given invalid visitor information" do
      let(:visitor_hash) do
        {
          visit: {
            visitor: [
              first_name: '',
              last_name: '',
              date_of_birth: '1988-03-14',
              email: 'sue.denim@gmail.com',
              phone: '07783 123 456'
            ]
          },
          next: ''
        }
      end

      before :each do
        get :prisoner_details
      end

      it "rejects visitor information" do
        post :update_visitor_details, visitor_hash
        response.should redirect_to(visitor_details_path)
        session[:visit].visitors[0].should_not be_valid
      end
    end

    context "given too many visitors" do
      let(:visitor_hash) do
        {
          visit: {
            visitor: [
              first_name: 'Sue',
              last_name: 'Demin',
              date_of_birth: '1988-03-14',
              email: 'sue.denim@gmail.com',
              phone: '07783 123 456'
            ] * 7
          },
          next: ''
        }
      end

      before :each do
        get :prisoner_details
      end

      it "rejects the submission if there are too many visitors" do
        post :update_visitor_details, visitor_hash
        response.should redirect_to(visitor_details_path)
        session[:visit].should_not be_valid
      end
    end
  end

  describe "step 4 - select a timeslot" do
    before :each do
      get :prisoner_details
    end

    context "correct slot information" do
      let(:slots_hash) do
        {
          visit: {
            slots: [
              {
                slot: '2013-01-01-1345-2000'
              }
            ]
          }
        }
      end

      it "permits us to select a time slot" do
        post :update_visit_details, slots_hash
        response.should redirect_to(summary_path)
      end
    end

    context "no slots" do
      let(:slots_hash) do
        {
          visit: { slots: [{slot: ''}] }
        }
      end

      it "prompts us to retry" do
        post :update_visit_details, slots_hash
        response.should redirect_to(visit_details_path)
      end
    end

    context "exactly three slots" do
      let(:slots_hash) do
        {
          visit: { slots: [{slot: '2013-01-01-1200-1300'}] * 3 }
        }
      end

      it "accepts the submission" do
        post :update_visit_details, slots_hash
        response.should redirect_to(summary_path)
      end
    end

    context "exactly two slots" do
      let(:slots_hash) do
        {
          visit: { slots: [{slot: '2013-01-01-1200-1300'}] * 2 }
        }
      end

      it "accepts the submission" do
        post :update_visit_details, slots_hash
        response.should redirect_to(summary_path)
      end
    end

    context "too many slots" do
      let(:slots_hash) do
        {
          visit: { slots: [{ slot: '2013-01-01-1200-1300' }] * 4 }
        }
      end

      it "prompts us to retry" do
        post :update_visit_details, slots_hash
        response.should redirect_to(visit_details_path)
        session[:visit].errors[:slots].should_not be_nil
      end
    end
  end

  describe "abandon ship!" do
    before :each do
      get :prisoner_details
    end

    it "should clear out the session" do
      get :abandon
      session[:visit].should be_nil
    end
  end
end
