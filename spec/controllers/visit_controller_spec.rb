require 'spec_helper'

describe VisitController do
  render_views

  describe "step 1 - enter prisoner's details" do
    before :each do
      ActionMailer::Base.deliveries.clear
      Timecop.freeze(Time.local(2013, 12, 1, 12, 00))
    end

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
            :'date_of_birth(3i)' => '20',
            :'date_of_birth(2i)' => '04',
            :'date_of_birth(1i)' => '1986',
            number: 'g3133ff',
            prison_name: 'Rochester'
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

      it "updates prisoner details with bad date and redirects back" do
        bad_prisoner_hash = prisoner_hash.dup
        bad_prisoner_hash[:prisoner].except!(:'date_of_birth(3i)', :'date_of_birth(2i)', :'date_of_birth(1i)')
        post :update_prisoner_details, bad_prisoner_hash
        response.should redirect_to(prisoner_details_path)
      end
    end

    context "given invalid prisoner details" do
      let(:prisoner_hash) do
        {
          prisoner: {
            first_name: '',
            last_name: '',
            :'date_of_birth(3i)' => '20',
            :'date_of_birth(2i)' => '04',
            :'date_of_birth(1i)' => '1986',
            number: '31337',
            prison_name: 'Rochester'
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
    before :each do
      Timecop.freeze(Time.local(2013, 12, 1, 12, 00))
    end

    context "given valid visitor information" do
      let(:visitor_hash) do
        {
          visit: {
            visitor: [
              first_name: 'Sue',
              last_name: 'Demin',
              :'date_of_birth(3i)' => '14',
              :'date_of_birth(2i)' => '03',
              :'date_of_birth(1i)' => '1986',
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
              :'date_of_birth(3i)' => '14',
              :'date_of_birth(2i)' => '03',
              :'date_of_birth(1i)' => '1986',
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
              :'date_of_birth(3i)' => '14',
              :'date_of_birth(2i)' => '03',
              :'date_of_birth(1i)' => '1986',
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
        session[:visit].valid?(:visitors_set).should be_false
      end
    end

    context "given too many adult visitors" do
      let(:visitor_hash) do
        {
          visit: {
            visitor: [
              [
                first_name: 'Sue',
                last_name: 'Demin',
                :'date_of_birth(3i)' => '14',
                :'date_of_birth(2i)' => '03',
                :'date_of_birth(1i)' => '1986',
                email: 'sue.denim@gmail.com',
                phone: '07783 123 456'
              ],
              [
                first_name: 'John',
                last_name: 'Denver',
                :'date_of_birth(3i)' => '31',
                :'date_of_birth(2i)' => '12',
                :'date_of_birth(1i)' => '1943'
              ] * 3
            ].flatten
          },
          next: ''
        }
      end

      before :each do
        get :prisoner_details
      end

      it "rejects the submission if there are too many adult visitors" do
        post :update_visitor_details, visitor_hash
        response.should redirect_to(visitor_details_path)
        session[:visit].valid?(:visitors_set).should be_false
      end
    end
  end

  describe "step 4 - select a timeslot" do
    before :each do
      Timecop.freeze(Time.local(2013, 12, 1, 12, 0))
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
        post :update_choose_date_and_time, slots_hash
        response.should redirect_to(check_your_request_path)
      end
    end

    context "no slots" do
      let(:slots_hash) do
        {
          visit: { slots: [{slot: ''}] }
        }
      end

      it "prompts us to retry" do
        post :update_choose_date_and_time, slots_hash
        response.should redirect_to(choose_date_and_time_path)
      end
    end

    context "exactly three slots" do
      let(:slots_hash) do
        {
          visit: { slots: [{slot: '2013-01-01-1200-1300'}] * 3 }
        }
      end

      it "accepts the submission" do
        post :update_choose_date_and_time, slots_hash
        response.should redirect_to(check_your_request_path)
      end
    end

    context "exactly two slots" do
      let(:slots_hash) do
        {
          visit: { slots: [{slot: '2013-01-01-1200-1300'}] * 2 }
        }
      end

      it "accepts the submission" do
        post :update_choose_date_and_time, slots_hash
        response.should redirect_to(check_your_request_path)
      end
    end

    context "too many slots" do
      let(:slots_hash) do
        {
          visit: { slots: [{ slot: '2013-01-01-1200-1300' }] * 4 }
        }
      end

      it "prompts us to retry" do
        post :update_choose_date_and_time, slots_hash
        response.should redirect_to(choose_date_and_time_path)
        session[:visit].errors[:slots].should_not be_nil
      end
    end
  end

  describe "step 5" do
    before :each do
      Timecop.freeze(Time.local(2013, 12, 1, 12, 0))

      session[:visit] = Visit.new.tap do |v|
        v.prisoner = Prisoner.new.tap do |p|
          p.first_name = 'Jimmy'
          p.last_name = 'Fingers'
          p.number = 'aa1111aa'
          p.prison_name = 'Rochester'
          p.date_of_birth = Date.new(1975, 1, 1)
        end

        v.visitors = [Visitor.new.tap do |vi|
          vi.first_name = 'Morvern'
          vi.last_name = 'Callar'
          vi.email = 'email@system.lol'
          vi.index = 0
          vi.phone = '01234567890'
          vi.date_of_birth = Date.today - 20.years
        end]

        v.slots = [Slot.new(date: '2013-12-06', times: '0945-1115')]
      end
    end

    it "displays a summary" do
      get :check_your_request
      response.should be_success
    end

    it "sends out emails" do
      subject.should_receive(:encryptor).and_return(VisitStateEncryptor.new("LOL" * 48))

      BookingRequest.any_instance.should_receive(:sender).and_return('test@example.com')
      BookingConfirmation.any_instance.should_receive(:sender).and_return('test@example.com')

      post :update_check_your_request
      response.should redirect_to(request_sent_path)

      ActionMailer::Base.deliveries.map(&:subject).should == ['Visit request for Jimmy Fingers', 'Your visit request for 6 December 2013']
    end
  end

  describe "abandon ship!" do
    before :each do
      Timecop.freeze(Time.local(2013, 12, 1, 12, 0))

      get :prisoner_details
    end

    it "should clear out the session" do
      get :abandon
      session[:visit].should be_nil
    end
  end

  context "when accessing the service out of business hours" do
    before :each do
      Timecop.freeze(Time.local(2013, 12, 1, 23, 30))
    end

    it "displays an appropriate message" do
      get :prisoner_details
      response.should redirect_to(unavailable_path)
    end
  end
end
