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
      controller.stub(:check_ip_ranges)
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
        response.should redirect_to(confirmation_path)
      end
    end

    it "bails out if the state is corrupt or not present" do
      expect {
        get :new
      }.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
      
      expect {
        get :new, state: 'bad state'
      }.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
    end
  end

  context "interaction" do
    before :each do
      controller.stub(:booked_visit).and_return(visit)
      ActionMailer::Base.deliveries.clear
      VisitorMailer.any_instance.stub(:sender).and_return('test@example.com')
      PrisonMailer.any_instance.stub(:sender).and_return('test@example.com')
      controller.stub(:metrics_logger).and_return(mock_metrics_logger)
      controller.stub(:check_ip_ranges)
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
        ActionMailer::Base.deliveries.map(&:subject).should == ["Your visit for 7 July 2013 has been confirmed.", "Booking receipt for Jimmy Fingers"]
      end
    end

    context "when a form is submitted indicating the visitor is not on the contact list" do
      it "sends out an e-mail and records a metric" do
        controller.should_receive(:reset_session).once
        mock_metrics_logger.should_receive(:record_booking_rejection).with(visit, 'not_on_contact_list')
        VisitorMailer.should_receive(:booking_rejection_email).with(visit, an_instance_of(Confirmation)).once.and_call_original
        PrisonMailer.should_receive(:booking_receipt_email).with(visit, an_instance_of(Confirmation)).once.and_call_original 
      end

      after :each do
        post :create, confirmation: { outcome: 'not_on_contact_list' }
        response.should redirect_to(confirmation_path)
        ActionMailer::Base.deliveries.map(&:subject).should == ["Your visit for 7 July 2013 could not be booked.", "Booking receipt for Jimmy Fingers"]
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
        ActionMailer::Base.deliveries.map(&:subject).should == ["Your visit for 7 July 2013 could not be booked.", "Booking receipt for Jimmy Fingers"]
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
