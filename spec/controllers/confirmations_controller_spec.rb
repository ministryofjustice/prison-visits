require 'spec_helper'

describe ConfirmationsController do
  render_views

  let :mock_metrics_logger do
    double('metrics_logger')
  end

  let :visit do
    sample_visit
  end

  context "before interaction" do
    before :each do
      controller.stub(:metrics_logger).and_return(mock_metrics_logger)
      controller.stub(:reject_untrusted_ips!)
    end

    it "resurrects the visit" do
      mock_metrics_logger.should_receive(:record_link_click)
      mock_metrics_logger.should_receive(:processed?) do |v|
        v.should.eql? visit
        false
      end
      get :new, state: MESSAGE_ENCRYPTOR.encrypt_and_sign(visit)
      subject.booked_visit.should.equal? visit
      response.should be_success
      response.should render_template('confirmations/new')
    end

    it "doesn't resurrect a visit which has already been booked" do
      sample_visit.tap do |visit|
        mock_metrics_logger.should_receive(:record_link_click)
        mock_metrics_logger.should_receive(:processed?) do |v|
          v.should.eql? visit
          true
        end
        get :new, state: MESSAGE_ENCRYPTOR.encrypt_and_sign(visit)
        response.should be_success
        response.should render_template('confirmations/_already_booked')
      end
    end

    ['Liverpool', 'Winchester', 'Bullingdon'].each do |prison_name|
      it "resurrects a visit with a old prison name (#{prison_name}) to avoid a runtime exception" do
        sample_visit.tap do |visit|
          visit.prisoner.prison_name = prison_name
          mock_metrics_logger.should_receive(:record_link_click)
          mock_metrics_logger.should_receive(:processed?) do |v|
            v.should.eql? visit
            false
          end
          get :new, state: MESSAGE_ENCRYPTOR.encrypt_and_sign(visit)
          response.should be_success
          response.should render_template('confirmations/new')
          controller.booked_visit.prisoner.prison_name.should_not == prison_name
        end
      end
    end

    it "bails out if the state is corrupt or not present" do
      get :new
      response.status.should == 400
      response.should render_template('confirmations/_bad_state')
      
      get :new, state: 'bad state'
      response.status.should == 400
      response.should render_template('confirmations/_bad_state')
    end
  end

  context "interaction" do
    before :each do
      controller.stub(:booked_visit).and_return(visit)
      ActionMailer::Base.deliveries.clear
      VisitorMailer.any_instance.stub(:sender).and_return('test@example.com')
      PrisonMailer.any_instance.stub(:sender).and_return('test@example.com')
      controller.stub(:metrics_logger).and_return(mock_metrics_logger)
      controller.stub(:reject_untrusted_ips!)
    end

    context "when a form is submitted with a slot selected" do
      it "sends out an e-mail and records a metric" do
        controller.should_receive(:reset_session).once
        mock_metrics_logger.should_receive(:record_booking_confirmation).with(visit)
        VisitorMailer.should_receive(:booking_confirmation_email).with(visit, an_instance_of(Confirmation)).once.and_call_original
        PrisonMailer.should_receive(:booking_receipt_email).with(visit, an_instance_of(Confirmation)).once.and_call_original
      end

      after :each do
        post :create, confirmation: { outcome: 'slot_0' }
        response.should redirect_to(confirmation_path)
        ActionMailer::Base.deliveries.map(&:subject).should == ["Your visit for 7 July 2013 has been confirmed", "COPY of booking confirmation for Jimmy Fingers"]
      end
    end

    context "when a form is submitted indicating the visitor is not on the contact list" do
      it "sends out an e-mail and records a metric" do
        controller.should_receive(:reset_session).once
        mock_metrics_logger.should_receive(:record_booking_rejection).with(visit, Confirmation::NOT_ON_CONTACT_LIST)
        VisitorMailer.should_receive(:booking_rejection_email).with(visit, an_instance_of(Confirmation)).once.and_call_original
        PrisonMailer.should_receive(:booking_receipt_email).with(visit, an_instance_of(Confirmation)).once.and_call_original 
      end

      after :each do
        post :create, confirmation: { outcome: Confirmation::NOT_ON_CONTACT_LIST }
        response.should redirect_to(confirmation_path)
        ActionMailer::Base.deliveries.map(&:subject).should == ["Your visit for 7 July 2013 could not be booked", "COPY of booking rejection for Jimmy Fingers"]
      end
    end

    context "when a form is submitted and no VOs are available" do
      it "sends out an e-mail and records a metric" do
        controller.should_receive(:reset_session).once
        mock_metrics_logger.should_receive(:record_booking_rejection).with(visit, Confirmation::NO_VOS_LEFT)
        VisitorMailer.should_receive(:booking_rejection_email).with(visit, an_instance_of(Confirmation)).once.and_call_original
        PrisonMailer.should_receive(:booking_receipt_email).with(visit, an_instance_of(Confirmation)).once.and_call_original 
      end

      after :each do
        post :create, confirmation: { outcome: Confirmation::NO_VOS_LEFT }
        response.should redirect_to(confirmation_path)
        ActionMailer::Base.deliveries.map(&:subject).should == ["Your visit for 7 July 2013 could not be booked", "COPY of booking rejection for Jimmy Fingers"]
      end
    end

    context "when a form is submitted without a slot" do
      it "sends out an e-mail and records a metric" do
        controller.should_receive(:reset_session).once
        mock_metrics_logger.should_receive(:record_booking_rejection).with(visit, 'no_slot_available')
        VisitorMailer.should_receive(:booking_rejection_email).with(visit, an_instance_of(Confirmation)).once.and_call_original
        PrisonMailer.should_receive(:booking_receipt_email).with(visit, an_instance_of(Confirmation)).once.and_call_original 
      end

      after :each do
        post :create, confirmation: { outcome: 'no_slot_available' }
        response.should redirect_to(confirmation_path)
        ActionMailer::Base.deliveries.map(&:subject).should == ["Your visit for 7 July 2013 could not be booked", "COPY of booking rejection for Jimmy Fingers"]
      end
    end

    context "when a link is clicked" do
      it "records the metrics" do
        mock_metrics_logger.should_receive(:record_link_click).with(visit)
        mock_metrics_logger.should_receive(:processed?).with(visit)
      end

      after :each do
        get :new, state: MESSAGE_ENCRYPTOR.encrypt_and_sign(visit)
      end
    end

    context "when an incomplete form is submitted" do
      it "redirects back to the new action" do
        post :create, confirmation: { outcome: 'lol' }
        response.should render_template('confirmations/new')
      end
    end
  end

  context "IP restrictions" do
    it "denies all other requests" do
      Rails.configuration.stub(:permitted_ips_for_confirmations).and_return(['127.0.0.2'])
      expect {
        get :new
      }.to raise_error(ActionController::RoutingError)
    end
  end
end
