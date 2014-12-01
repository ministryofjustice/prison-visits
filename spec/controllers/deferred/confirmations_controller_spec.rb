require 'spec_helper'

describe Deferred::ConfirmationsController do
  render_views

  let :mock_metrics_logger do
    double('metrics_logger')
  end

  let :visit do
    sample_visit
  end

  let :encrypted_visit do
    MESSAGE_ENCRYPTOR.encrypt_and_sign(visit)
  end

  context "in correct IP range" do
    context "before interaction" do
      before :each do
        controller.stub(:metrics_logger).and_return(mock_metrics_logger)
        controller.stub(:reject_untrusted_ips!)
      end

      it "resurrects the visit" do
        controller.should_receive(:logstasher_add_visit_id).with(visit.visit_id)
        mock_metrics_logger.should_receive(:record_link_click)
        mock_metrics_logger.should_receive(:processed?) do |v|
          v.should.eql? visit
          false
        end
        get :new, state: encrypted_visit
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
          get :new, state: encrypted_visit
          response.should be_success
          response.should render_template('confirmations/_already_booked')
        end
      end

      ['Hollesley Bay', 'Hatfield (moorland Open)', 'Highpoint', 'Albany', 'Parkhurst', 'Liverpool (Open only)'].each do |prison_name|
        it "resurrects a visit with a old prison name (#{prison_name}) to avoid a runtime exception" do
          sample_visit.tap do |visit|
            visit.prisoner.prison_name = prison_name
            controller.should_receive(:logstasher_add_visit_id).with(visit.visit_id)
            mock_metrics_logger.should_receive(:record_link_click)
            mock_metrics_logger.should_receive(:processed?) do |v|
              v.should.eql? visit
              false
            end
            get :new, state: encrypted_visit
            response.should be_success
            response.should render_template('confirmations/new')
            controller.booked_visit.prisoner.prison_name.should_not == prison_name
          end
        end
      end

      it "bails out if the state is not present" do
        get :new
        response.status.should == 400
        response.should render_template('confirmations/_bad_state')
      end
      
      it "bails out if the state is corrupt" do
        get :new, state: 'bad state'
        response.status.should == 400
        response.should render_template('confirmations/_bad_state')
      end
    end

    context "interaction" do
      context "open responses" do

        before :each do
          ActionMailer::Base.deliveries.clear
          VisitorMailer.any_instance.stub(:sender).and_return('test@example.com')
          PrisonMailer.any_instance.stub(:sender).and_return('test@example.com')
          controller.stub(:metrics_logger).and_return(mock_metrics_logger)
          controller.stub(:reject_untrusted_ips!)
        end

        context "when a form is submitted with a slot selected" do
          it "sends out an e-mail and records a metric" do
            mock_metrics_logger.should_receive(:record_booking_confirmation) { |actual_visit| visit.should.eql? actual_visit }
            VisitorMailer.should_receive(:booking_confirmation_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
            PrisonMailer.should_receive(:booking_receipt_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
          end

          after :each do
            post :create, confirmation: { outcome: 'slot_0' }, state: encrypted_visit
            response.should redirect_to(deferred_confirmation_path)
            ActionMailer::Base.deliveries.map(&:subject).should == ["Visit confirmed: your visit for 7 July 2013 has been confirmed", "COPY of booking confirmation for Jimmy Harris"]
          end
        end

        context "when a form is submitted indicating the visitor is not on the contact list" do
          it "sends out an e-mail and records a metric" do
            mock_metrics_logger.should_receive(:record_booking_rejection) { |actual_visit, reason| visit.should.eql? actual_visit; reason.should == Confirmation::NOT_ON_CONTACT_LIST }
            VisitorMailer.should_receive(:booking_rejection_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
            PrisonMailer.should_receive(:booking_receipt_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
          end

          after :each do
            post :create, confirmation: { outcome: Confirmation::NOT_ON_CONTACT_LIST }, state: encrypted_visit
            response.should redirect_to(deferred_confirmation_path)
            ActionMailer::Base.deliveries.map(&:subject).should == ["Visit cannot take place: your visit for 7 July 2013 could not be booked", "COPY of booking rejection for Jimmy Harris"]
          end
        end

        context "when a form is submitted and no VOs are available" do
          it "sends out an e-mail and records a metric" do
            mock_metrics_logger.should_receive(:record_booking_rejection) { |actual_visit, reason| visit.should.eql? actual_visit; reason.should == Confirmation::NO_VOS_LEFT }
            VisitorMailer.should_receive(:booking_rejection_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
            PrisonMailer.should_receive(:booking_receipt_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
          end

          after :each do
            post :create, confirmation: { outcome: Confirmation::NO_VOS_LEFT }, state: encrypted_visit
            response.should redirect_to(deferred_confirmation_path)
            ActionMailer::Base.deliveries.map(&:subject).should == ["Visit cannot take place: your visit for 7 July 2013 could not be booked", "COPY of booking rejection for Jimmy Harris"]
          end
        end

        context "when a form is submitted without a slot" do
          it "sends out an e-mail and records a metric" do
            mock_metrics_logger.should_receive(:record_booking_rejection) { |actual_visit, reason| actual_visit.should.eql? visit; reason.should == Confirmation::NO_SLOT_AVAILABLE }
            VisitorMailer.should_receive(:booking_rejection_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
            PrisonMailer.should_receive(:booking_receipt_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
          end

          after :each do
            post :create, confirmation: { outcome: Confirmation::NO_SLOT_AVAILABLE }, state: encrypted_visit
            response.should redirect_to(deferred_confirmation_path)
            ActionMailer::Base.deliveries.map(&:subject).should == ["Visit cannot take place: your visit for 7 July 2013 could not be booked", "COPY of booking rejection for Jimmy Harris"]
          end
        end

        context "when a link is clicked" do
          it "records the metrics" do
            mock_metrics_logger.should_receive(:record_link_click) { |actual_visit| visit.should.eql? actual_visit }
            mock_metrics_logger.should_receive(:processed?) { |actual_visit| visit.should.eql? actual_visit }
          end

          after :each do
            get :new, state: encrypted_visit
          end
        end

        context "when an incomplete form is submitted" do
          it "redirects back to the new action" do
            post :create, confirmation: { outcome: 'lol' }, state: encrypted_visit
            response.should render_template('confirmations/new')
          end
        end

        context "when the thank you screen is accessed" do
          it "resets the session" do
            controller.should_receive(:reset_session).once
            get :show, state: encrypted_visit
            response.should render_template('confirmations/show')
          end
        end

      end

      context "canned responses" do

        before :each do
          ActionMailer::Base.deliveries.clear
          VisitorMailer.any_instance.stub(:sender).and_return('test@example.com')
          PrisonMailer.any_instance.stub(:sender).and_return('test@example.com')
          controller.stub(:metrics_logger).and_return(mock_metrics_logger)
          controller.stub(:reject_untrusted_ips!)
        end

        context "when a form is submitted with a slot selected" do
          it "sends out an e-mail and records a metric" do
            mock_metrics_logger.should_receive(:record_booking_confirmation) { |actual_visit| visit.should.eql? actual_visit }
            VisitorMailer.should_receive(:booking_confirmation_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
            PrisonMailer.should_receive(:booking_receipt_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
          end

          after :each do
            post :create, confirmation: { outcome: 'slot_0', vo_number: '55512345', canned_response: true }, state: encrypted_visit
            response.should redirect_to(deferred_confirmation_path)
            ActionMailer::Base.deliveries.map(&:subject).should == ["Visit confirmed: your visit for 7 July 2013 has been confirmed", "COPY of booking confirmation for Jimmy Harris"]
          end
        end

        context "when a form is submitted with banned or unlisted visitors and a succesful slot allocation" do
          before :each do
            mock_metrics_logger.should_receive(:record_booking_confirmation) { |actual_visit| visit.should.eql? actual_visit }
            VisitorMailer.should_receive(:booking_confirmation_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
            PrisonMailer.should_receive(:booking_receipt_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
          end

          it "sends out an e-mail for an unlisted visitor" do
            post :create, confirmation: { outcome: 'slot_0', vo_number: '555123345', canned_response: true, visitor_not_listed: true, unlisted_visitors: ['Mark;Harris']}, state: encrypted_visit
          end

          it "sends out an e-mail for a banned visitor" do
            post :create, confirmation: { outcome: 'slot_0', vo_number: '555123345', canned_response: true, visitor_banned: true, banned_visitors: ['Mark;Harris']}, state: encrypted_visit
          end

          it "sends out an e-mail for both banned an unlisted visitor" do
            post :create, confirmation: { outcome: 'slot_0', vo_number: '555123345', canned_response: true, visitor_banned: true, banned_visitors: ['Mark;Harris'], visitor_not_listed: true, unlisted_visitors: ['Joan;Harris']}, state: encrypted_visit
          end

          after :each do
            response.should redirect_to(deferred_confirmation_path)
            ActionMailer::Base.deliveries.map(&:subject).should == ["Visit confirmed: your visit for 7 July 2013 has been confirmed", "COPY of booking confirmation for Jimmy Harris"]
          end
        end

        context "when a form is submitted with banned or unlisted visitors and no other outcome" do
          before :each do
            mock_metrics_logger.should_receive(:record_booking_rejection) { |actual_visit| visit.should.eql? actual_visit }
            VisitorMailer.should_receive(:booking_rejection_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
            PrisonMailer.should_receive(:booking_receipt_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
          end

          it "sends rejection e-mail for an unlisted visitor" do
            post :create, confirmation: { canned_response: true, visitor_not_listed: true, unlisted_visitors: ['Mark;Harris']}, state: encrypted_visit
          end

          it "sends rejection e-mail for a banned visitor" do
            post :create, confirmation: { canned_response: true, visitor_banned: true, banned_visitors: ['Mark;Harris']}, state: encrypted_visit
          end

          it "sends rejection e-mail for both banned an unlisted visitor" do
            post :create, confirmation: { canned_response: true, visitor_banned: true, banned_visitors: ['Mark;Harris'], visitor_not_listed: true, unlisted_visitors: ['Joan;Harris']}, state: encrypted_visit
          end

          after :each do
            response.should redirect_to(deferred_confirmation_path)
            ActionMailer::Base.deliveries.map(&:subject).should == ["Visit cannot take place: your visit for 7 July 2013 could not be booked", "COPY of booking rejection for Jimmy Harris"]
          end
        end

        context "when a form is submitted and the prisoner has no allowance remaining" do
          before :each do
            mock_metrics_logger.should_receive(:record_booking_rejection) { |actual_visit, reason| visit.should.eql? actual_visit; reason.should == Confirmation::NO_ALLOWANCE }
            VisitorMailer.should_receive(:booking_rejection_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
            PrisonMailer.should_receive(:booking_receipt_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
          end

          it "sends out an e-mail and records a metric" do
            post :create, confirmation: { outcome: Confirmation::NO_ALLOWANCE, canned_response: true }, state: encrypted_visit
          end

          it "sends out an e-mail with VO renewal date and records a metric" do
            post :create, confirmation: { outcome: Confirmation::NO_ALLOWANCE, canned_response: true, no_vo: true, renew_vo: '2014-11-28' }, state: encrypted_visit
          end

          it "sends out an e-mail with VO & PVO renewal dates and records a metric" do
            post :create, confirmation: { outcome: Confirmation::NO_ALLOWANCE, canned_response: true, no_vo: true, renew_vo: '2014-11-28', no_pvo: true, renew_pvo: '2014-12-10' }, state: encrypted_visit
          end

          after :each do
            response.should redirect_to(deferred_confirmation_path)
            ActionMailer::Base.deliveries.map(&:subject).should == ["Visit cannot take place: your visit for 7 July 2013 could not be booked", "COPY of booking rejection for Jimmy Harris"]
          end
        end

        context "when a form is submitted and the prisoner details are incorrect" do
          it "sends out an e-mail and records a metric" do
            mock_metrics_logger.should_receive(:record_booking_rejection) { |actual_visit, reason| actual_visit.should.eql? visit; reason.should == Confirmation::PRISONER_INCORRECT }
            VisitorMailer.should_receive(:booking_rejection_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
            PrisonMailer.should_receive(:booking_receipt_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
          end

          after :each do
            post :create, confirmation: { outcome: Confirmation::PRISONER_INCORRECT, canned_response: true }, state: encrypted_visit
            response.should redirect_to(deferred_confirmation_path)
            ActionMailer::Base.deliveries.map(&:subject).should == ["Visit cannot take place: your visit for 7 July 2013 could not be booked", "COPY of booking rejection for Jimmy Harris"]
          end
        end

        context "when a form is submitted and the prisoner is not at the prison" do
          it "sends out an e-mail and records a metric" do
            mock_metrics_logger.should_receive(:record_booking_rejection) { |actual_visit, reason| actual_visit.should.eql? visit; reason.should == Confirmation::PRISONER_NOT_PRESENT }
            VisitorMailer.should_receive(:booking_rejection_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
            PrisonMailer.should_receive(:booking_receipt_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
          end

          after :each do
            post :create, confirmation: { outcome: Confirmation::PRISONER_NOT_PRESENT, canned_response: true }, state: encrypted_visit
            response.should redirect_to(deferred_confirmation_path)
            ActionMailer::Base.deliveries.map(&:subject).should == ["Visit cannot take place: your visit for 7 July 2013 could not be booked", "COPY of booking rejection for Jimmy Harris"]
          end
        end

        context "when a form is submitted without a slot" do
          it "sends out an e-mail and records a metric" do
            mock_metrics_logger.should_receive(:record_booking_rejection) { |actual_visit, reason| actual_visit.should.eql? visit; reason.should == Confirmation::NO_SLOT_AVAILABLE }
            VisitorMailer.should_receive(:booking_rejection_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
            PrisonMailer.should_receive(:booking_receipt_email) { |actual_visit, confirmation| visit.should.eql? actual_visit; confirmation.should be an_instance_of(Confirmation) }.once.and_call_original
          end

          after :each do
            post :create, confirmation: { outcome: Confirmation::NO_SLOT_AVAILABLE, canned_response: true }, state: encrypted_visit
            response.should redirect_to(deferred_confirmation_path)
            ActionMailer::Base.deliveries.map(&:subject).should == ["Visit cannot take place: your visit for 7 July 2013 could not be booked", "COPY of booking rejection for Jimmy Harris"]
          end
        end

        context "when an incomplete form is submitted" do
          it "redirects back to the new action" do
            post :create, confirmation: { outcome: 'lol', canned_response: true }, state: encrypted_visit
            response.should render_template('confirmations/new')
          end
        end

        context "when the thank you screen is accessed" do
          it "resets the session" do
            controller.should_receive(:reset_session).once
            get :show, state: encrypted_visit
            response.should render_template('confirmations/show')
          end
        end

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
