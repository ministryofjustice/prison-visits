require 'spec_helper'

describe VisitController do
  render_views

  after :all do
    Timecop.return
  end

  before :each do
    ActionMailer::Base.deliveries.clear
    controller.stub(:service_domain => 'lol.biz.info')
    request.stub(:ssl? => true)
  end

  let(:prisoner_hash) do
    {
      prisoner: {
        first_name: 'Jimmy',
        last_name: 'Harris',
        :'date_of_birth(3i)' => '20',
        :'date_of_birth(2i)' => '04',
        :'date_of_birth(1i)' => '1986',
        number: 'g3133ff',
        prison_name: 'Rochester'
      }
    }
  end

  context "always" do
    let :visit_id do
      SecureRandom.hex
    end

    it "displays the status of a visit not yet created" do
      controller.metrics_logger.should_receive(:visit_status).with(visit_id).twice.and_return(false)
      get :status, id: visit_id 
      response.status.should == 200
    end

    it "displays the status of an unprocessed visit" do
      controller.metrics_logger.should_receive(:visit_status).with(visit_id).and_return(:pending)
    end

    it "displays the status of a confirmed visit" do
      controller.metrics_logger.should_receive(:visit_status).with(visit_id).and_return(:confirmed)
    end

    it "displays the status of a rejected visit" do
      controller.metrics_logger.should_receive(:visit_status).with(visit_id).and_return(:rejected)
    end

    after :each do
      get :status, id: visit_id
      response.should be_success
    end
  end

  context "cookies are disabled" do
    it "redirects the user to a page telling them that they won't be able to use the site" do
      get :prisoner_details
      response.should be_success

      post :update_prisoner_details, prisoner_hash
      response.should redirect_to(cookies_disabled_path)
    end
  end

  context "cookies are enabled" do
    before :each do
      cookies['cookies-enabled'] = 1
    end

    describe "step 1 - enter prisoner's details" do
      before :each do
        Timecop.freeze(Time.local(2013, 12, 1, 12, 00))
      end

      it "renders the form for entering prisoner details, and assigns the session" do
        SecureRandom.should_receive(:hex).and_return(visit_id = 'LOL' * 10)
        controller.should_receive(:logstasher_add_visit_id).with(visit_id)
        expect {
          get :prisoner_details
          response.should be_success
        }.to change { session[:visit] }
      end

      it "sets the 'cookies-enabled' cookie" do
        get :prisoner_details
        response.should be_success
        response['Set-Cookie'].tap do |c|
          c.should =~ /secure/i
          c.should =~ /httponly/i
          c.should =~ /domain=lol.biz.info/i
        end
      end

      context "given valid prisoner details" do
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

        it "doesn't accept the year as having two digits" do
          prisoner_hash[:prisoner][:'date_of_birth(3i)'] = '5'
          prisoner_hash[:prisoner][:'date_of_birth(2i)'] = '2'
          prisoner_hash[:prisoner][:'date_of_birth(1i)'] = '12'
          post :update_prisoner_details, prisoner_hash
          response.should redirect_to(prisoner_details_path)
        end

        it "sets the testing flag if 'test' is passed in on the first screen" do
          get :prisoner_details, testing: 1
          session[:just_testing].should be_true
        end

        context "whitespace trimming" do
          it "removes whitespace from strings" do
            post :update_prisoner_details, { prisoner: { first_name: ' Jimmy ', last_name: ' Harris ', prison_name: 'Rochester' } }
            controller.visit.prisoner.first_name.should == 'Jimmy'
            controller.visit.prisoner.last_name.should == 'Harris'
          end
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
                        email: 'sue.denim@maildrop.dsd.io',
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
                        email: 'sue.denim@maildrop.dsd.io',
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

      context "given a visitor with two digit year component of DOB" do
        let :visitor_hash do
          {
            visit: {
              visitor: [
                        first_name: 'James',
                        last_name: 'Harris',
                        :'date_of_birth(3i)' => '5',
                        :'date_of_birth(2i)' => '3',
                        :'date_of_birth(1i)' => '12',
                        email: 'sue.denim@maildrop.dsd.io',
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
                        email: 'sue.denim@maildrop.dsd.io',
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
                         email: 'sue.denim@maildrop.dsd.io',
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

      context "whitespace trimming" do
        let(:visitor_hash) do
          {
            visit: {
              visitor: [
                        first_name: ' Sue ',
                        last_name: ' Demin ',
                        :'date_of_birth(3i)' => '14',
                        :'date_of_birth(2i)' => '03',
                        :'date_of_birth(1i)' => '1986',
                        email: 'sue.denim@maildrop.dsd.io',
                        phone: '07783 123 456'
                       ]
            },
            next: ''
          }
        end

        before :each do
          get :prisoner_details
        end

        it "removes whitespace from strings" do
          post :update_visitor_details, visitor_hash
          controller.visit.visitors.first.first_name.should == 'Sue'
          controller.visit.visitors.first.last_name.should == 'Demin'
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
            },
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
      let :mock_metrics_logger do
        MockMetricsLogger.new
      end

      before :each do
        Timecop.freeze(Time.local(2013, 12, 1, 12, 0))
        ActionMailer::Base.deliveries.clear
        subject.stub(:metrics_logger).and_return(mock_metrics_logger)

        session[:visit] = Visit.new.tap do |v|
          v.visit_id = SecureRandom.hex
          v.prisoner = Prisoner.new.tap do |p|
            p.first_name = 'Jimmy'
            p.last_name = 'Harris'
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
        mock_metrics_logger.should_receive(:record_visit_request).with(session[:visit])

        PrisonMailer.any_instance.should_receive(:sender).and_return('test@example.com')
        VisitorMailer.any_instance.should_receive(:sender).and_return('test@example.com')

        post :update_check_your_request
        response.should redirect_to(request_sent_path)

        ActionMailer::Base.deliveries.map(&:subject).should == ['Visit request for Jimmy Harris on Friday  6 December',
                                                                'Your visit request for 6 December 2013 will be processed soon']
      end

      it "doesn't send out e-mails if in testing mode" do
        controller.stub(:just_testing?).and_return(true)
        expect {
          post :update_check_your_request
          response.should redirect_to(request_sent_path)
          response.body.should_not include('ga(')
        }.not_to change { ActionMailer::Base.deliveries }
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

    describe "on session time out" do
      before :each do
        session.clear
      end

      [:update_prisoner_details, :update_visitor_details, :update_choose_date_and_time, :update_check_your_request].each do |a|
        it "redirects and displays timeout notice" do
          post a
          response.should redirect_to(prisoner_details_path)
          flash.notice.should == 'Your session timed out because no information was entered for more than 20 minutes.'
        end
      end
    end
  end

  context "browsing without a session present" do
    before :each do
      session.clear
    end

    [:visitor_details, :choose_date_and_time, :check_your_request, :request_sent].each do |action|
      it "and accessing #{action} redirects to the prisoner information page" do
        get action
        response.should redirect_to(prisoner_details_path)
      end
    end
  end
end
