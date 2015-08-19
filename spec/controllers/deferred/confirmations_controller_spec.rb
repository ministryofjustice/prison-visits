require 'rails_helper'

RSpec.describe Deferred::ConfirmationsController, type: :controller do
  include ActiveJobHelper

  render_views

  let(:mock_metrics_logger) { double('metrics_logger') }
  let(:visit) { sample_visit }
  let(:encrypted_visit) { MESSAGE_ENCRYPTOR.encrypt_and_sign(visit) }

  context "in correct IP range" do
    context "before interaction" do
      before do
        allow(controller).to receive(:metrics_logger).and_return(mock_metrics_logger)
        allow(controller).to receive(:reject_untrusted_ips!)
      end

      it "resurrects the visit" do
        expect(controller).to receive(:logstasher_add_visit_id).with(visit.visit_id)
        expect(mock_metrics_logger).to receive(:request_cancelled?).and_return(false)
        expect(mock_metrics_logger).to receive(:record_link_click)
        expect(mock_metrics_logger).to receive(:processed?) do |v|
          expect(v).to be_same_visit(visit)
          false
        end
        get :new, state: encrypted_visit
        expect(subject.booked_visit).to be_same_visit(visit)
        expect(response).to be_success
        expect(response).to render_template('confirmations/new')
      end

      it "doesn't resurrect a visit which has already been booked" do
        expect(mock_metrics_logger).to receive(:request_cancelled?).and_return(true)
        expect(mock_metrics_logger).to receive(:record_link_click)
        expect(mock_metrics_logger).to receive(:processed?).and_return(false)
        get :new, state: encrypted_visit
        expect(response).to be_success
        expect(response).to render_template('confirmations/_request_cancelled')
      end

      it "doesn't resurrect a visit which has been cancelled by the visitor" do
        expect(mock_metrics_logger).to receive(:request_cancelled?).and_return(false)
        expect(mock_metrics_logger).to receive(:record_link_click)
        expect(mock_metrics_logger).to receive(:processed?) do |v|
          expect(v).to be_same_visit(visit)
          true
        end
        get :new, state: encrypted_visit
        expect(response).to be_success
        expect(response).to render_template('confirmations/_already_booked')
      end

      ['Hollesley Bay', 'Hatfield (moorland Open)', 'Highpoint', 'Albany', 'Parkhurst', 'Liverpool (Open only)'].each do |prison_name|
        it "resurrects a visit with a old prison name (#{prison_name}) to avoid a runtime exception" do
          visit.prisoner.prison_name = prison_name
          expect(controller).to receive(:logstasher_add_visit_id).with(visit.visit_id)
          expect(mock_metrics_logger).to receive(:request_cancelled?).and_return(false)
          expect(mock_metrics_logger).to receive(:record_link_click)
          expect(mock_metrics_logger).to receive(:processed?) do |v|
            expect(v).to be_same_visit(visit)
            false
          end
          get :new, state: encrypted_visit
          expect(response).to be_success
          expect(response).to render_template('confirmations/new')
          expect(controller.booked_visit.prisoner.prison_name).not_to eq(prison_name)
        end
      end

      it "bails out if the state is not present" do
        get :new
        expect(response.status).to eq(400)
        expect(response).to render_template('confirmations/_bad_state')
      end

      it "bails out if the state is corrupt" do
        get :new, state: 'bad state'
        expect(response.status).to eq(400)
        expect(response).to render_template('confirmations/_bad_state')
      end
    end

    context "interaction" do
      context "open responses" do

        before do
          ActionMailer::Base.deliveries.clear
          allow_any_instance_of(VisitorMailer).to receive(:sender).and_return('test@example.com')
          allow_any_instance_of(PrisonMailer).to receive(:sender).and_return('test@example.com')
          allow(controller).to receive(:metrics_logger).and_return(mock_metrics_logger)
          allow(controller).to receive(:reject_untrusted_ips!)
        end

        context "when a form is submitted with a slot selected" do
          it "sends out an e-mail and records a metric" do
            expect(mock_metrics_logger).
              to receive(:record_booking_confirmation).
              with(same_visit(visit))
          end

          after do
            post :create, confirmation: { outcome: 'slot_0' }, state: encrypted_visit
            expect(response).to redirect_to(deferred_show_confirmation_path(visit_id: visit.visit_id))
            expect(ActionMailer::Base.deliveries.map(&:subject)).to eq(
              [
                "Visit confirmed: your visit for 7 July 2013 has been confirmed",
                "COPY of booking confirmation for Jimmy Harris"
              ]
            )
          end
        end

        context "when a form is submitted indicating the visitor is not on the contact list" do
          it "sends out an e-mail and records a metric" do
            expect(mock_metrics_logger).
              to receive(:record_booking_rejection).
              with(same_visit(visit), Confirmation::NOT_ON_CONTACT_LIST)
          end

          after do
            post :create, confirmation: { outcome: Confirmation::NOT_ON_CONTACT_LIST }, state: encrypted_visit
            expect(response).to redirect_to(deferred_show_confirmation_path(visit_id: visit.visit_id))
            expect(ActionMailer::Base.deliveries.map(&:subject)).to eq(
              [
                "Visit cannot take place: your visit for 7 July 2013 could not be booked",
                "COPY of booking rejection for Jimmy Harris"
              ]
            )
          end
        end

        context "when a form is submitted and no VOs are available" do
          it "sends out an e-mail and records a metric" do
            expect(mock_metrics_logger).
              to receive(:record_booking_rejection).
              with(same_visit(visit), Confirmation::NO_VOS_LEFT)
          end

          after do
            post :create, confirmation: { outcome: Confirmation::NO_VOS_LEFT }, state: encrypted_visit
            expect(response).to redirect_to(deferred_show_confirmation_path(visit_id: visit.visit_id))
            expect(ActionMailer::Base.deliveries.map(&:subject)).to eq(
              [
                "Visit cannot take place: your visit for 7 July 2013 could not be booked",
                "COPY of booking rejection for Jimmy Harris"
              ]
            )
          end
        end

        context "when a form is submitted without a slot" do
          it "sends out an e-mail and records a metric" do
            expect(mock_metrics_logger).
              to receive(:record_booking_rejection).
              with(same_visit(visit), Confirmation::NO_SLOT_AVAILABLE)
          end

          after do
            post :create, confirmation: { outcome: Confirmation::NO_SLOT_AVAILABLE }, state: encrypted_visit
            expect(response).to redirect_to(deferred_show_confirmation_path(visit_id: visit.visit_id))
            expect(ActionMailer::Base.deliveries.map(&:subject)).to eq(["Visit cannot take place: your visit for 7 July 2013 could not be booked", "COPY of booking rejection for Jimmy Harris"])
          end
        end

        context "when a link is clicked" do
          it "records the metrics" do
            expect(mock_metrics_logger).to receive(:request_cancelled?).and_return(false)
            expect(mock_metrics_logger).to receive(:record_link_click) { |actual_visit|
              expect(visit).to be_same_visit(actual_visit)
            }
            expect(mock_metrics_logger).to receive(:processed?) { |actual_visit|
              expect(visit).to be_same_visit(actual_visit)
            }
          end

          after do
            get :new, state: encrypted_visit
          end
        end

        context "when an incomplete form is submitted" do
          it "redirects back to the new action" do
            post :create, confirmation: { outcome: 'lol' }, state: encrypted_visit
            expect(response).to render_template('confirmations/new')
          end
        end

        context "when the thank you screen is accessed" do
          it "resets the session" do
            expect(controller).to receive(:reset_session).once
            get :show, visit_id: visit.visit_id
            expect(response).to render_template('confirmations/show')
          end
        end

      end

      context "canned responses" do

        before do
          ActionMailer::Base.deliveries.clear
          allow_any_instance_of(VisitorMailer).to receive(:sender).and_return('test@example.com')
          allow_any_instance_of(PrisonMailer).to receive(:sender).and_return('test@example.com')
          allow(controller).to receive(:metrics_logger).and_return(mock_metrics_logger)
          allow(controller).to receive(:reject_untrusted_ips!)
        end

        context "when a form is submitted with a slot selected" do
          it "sends out an e-mail and records a metric" do
            expect(mock_metrics_logger).
              to receive(:record_booking_confirmation).
              with(same_visit(visit))
          end

          after do
            post :create, confirmation: { outcome: 'slot_0', vo_number: '55512345', canned_response: true }, state: encrypted_visit
            expect(response).to redirect_to(deferred_show_confirmation_path(visit_id: visit.visit_id))
            expect(ActionMailer::Base.deliveries.map(&:subject)).to eq(
              [
                "Visit confirmed: your visit for 7 July 2013 has been confirmed",
                "COPY of booking confirmation for Jimmy Harris"
              ]
            )
          end
        end

        context "when a form is submitted with banned or unlisted visitors and a succesful slot allocation" do
          before do
            expect(mock_metrics_logger).
              to receive(:record_booking_confirmation).
              with(same_visit(visit))
          end

          it "sends out an e-mail for an unlisted visitor" do
            post :create,
              confirmation: {
                outcome: 'slot_0', vo_number: '555123345',
                canned_response: true, visitor_not_listed: true,
                unlisted_visitors: ['Mark;Harris']
              },
              state: encrypted_visit
          end

          it "sends out an e-mail for a banned visitor" do
            post :create,
              confirmation: {
                outcome: 'slot_0', vo_number: '555123345',
                canned_response: true, visitor_banned: true,
                banned_visitors: ['Mark;Harris']
              },
              state: encrypted_visit
          end

          it "sends out an e-mail for both banned an unlisted visitor" do
            post :create,
              confirmation: {
                outcome: 'slot_0', vo_number: '555123345',
                canned_response: true, visitor_banned: true,
                banned_visitors: ['Mark;Harris'], visitor_not_listed: true,
                unlisted_visitors: ['Joan;Harris']
              },
              state: encrypted_visit
          end

          after do
            expect(response).to redirect_to(deferred_show_confirmation_path(visit_id: visit.visit_id))
            expect(ActionMailer::Base.deliveries.map(&:subject)).to eq(
              [
                "Visit confirmed: your visit for 7 July 2013 has been confirmed",
                "COPY of booking confirmation for Jimmy Harris"
              ]
            )
          end
        end

        context "when a form is submitted with banned or unlisted visitors and no other outcome" do
          before do
            expect(mock_metrics_logger).
              to receive(:record_booking_rejection).
              with(same_visit(visit), nil)
          end

          it "sends rejection e-mail for an unlisted visitor" do
            post :create,
              confirmation: {
                canned_response: true, visitor_not_listed: true,
                unlisted_visitors: ['Mark;Harris']
              },
              state: encrypted_visit
          end

          it "sends rejection e-mail for a banned visitor" do
            post :create,
              confirmation: {
                canned_response: true, visitor_banned: true,
                banned_visitors: ['Mark;Harris']
              },
              state: encrypted_visit
          end

          it "sends rejection e-mail for both banned an unlisted visitor" do
            post :create,
              confirmation: {
                canned_response: true, visitor_banned: true,
                banned_visitors: ['Mark;Harris'], visitor_not_listed: true,
                unlisted_visitors: ['Joan;Harris']
              },
              state: encrypted_visit
          end

          after do
            expect(response).to redirect_to(deferred_show_confirmation_path(visit_id: visit.visit_id))
            expect(ActionMailer::Base.deliveries.map(&:subject)).to eq(
              [
                "Visit cannot take place: your visit for 7 July 2013 could not be booked",
                "COPY of booking rejection for Jimmy Harris"
              ]
            )
          end
        end

        context "when a form is submitted and the prisoner has no allowance remaining" do
          before do
            expect(mock_metrics_logger).
              to receive(:record_booking_rejection).
              with(same_visit(visit), Confirmation::NO_ALLOWANCE)
          end

          it "sends out an e-mail and records a metric" do
            post :create,
              confirmation: {
                outcome: Confirmation::NO_ALLOWANCE, canned_response: true
              },
              state: encrypted_visit
          end

          it "sends out an e-mail with VO renewal date and records a metric" do
            post :create,
              confirmation: {
                outcome: Confirmation::NO_ALLOWANCE, canned_response: true,
                no_vo: true, renew_vo: '2014-11-28'
              },
              state: encrypted_visit
          end

          it "sends out an e-mail with VO & PVO renewal dates and records a metric" do
            post :create,
              confirmation: {
                outcome: Confirmation::NO_ALLOWANCE, canned_response: true,
                no_vo: true, renew_vo: '2014-11-28', no_pvo: true,
                renew_pvo: '2014-12-10'
              },
              state: encrypted_visit
          end

          after do
            expect(response).to redirect_to(deferred_show_confirmation_path(visit_id: visit.visit_id))
            expect(ActionMailer::Base.deliveries.map(&:subject)).to eq(
              [
                "Visit cannot take place: your visit for 7 July 2013 could not be booked",
                "COPY of booking rejection for Jimmy Harris"
              ]
            )
          end
        end

        context "when a form is submitted and the prisoner details are incorrect" do
          it "sends out an e-mail and records a metric" do
            expect(mock_metrics_logger).
              to receive(:record_booking_rejection).
              with(same_visit(visit), Confirmation::PRISONER_INCORRECT)
          end

          after do
            post :create,
              confirmation: {
                outcome: Confirmation::PRISONER_INCORRECT,
                canned_response: true
              },
              state: encrypted_visit
            expect(response).to redirect_to(deferred_show_confirmation_path(visit_id: visit.visit_id))
            expect(ActionMailer::Base.deliveries.map(&:subject)).to eq(
              [
                "Visit cannot take place: your visit for 7 July 2013 could not be booked",
                "COPY of booking rejection for Jimmy Harris"
              ]
            )
          end
        end

        context "when a form is submitted and the prisoner is not at the prison" do
          it "sends out an e-mail and records a metric" do
            expect(mock_metrics_logger).
              to receive(:record_booking_rejection).
              with(same_visit(visit), Confirmation::PRISONER_NOT_PRESENT)
          end

          after do
            post :create,
              confirmation: {
                outcome: Confirmation::PRISONER_NOT_PRESENT,
                canned_response: true
              },
              state: encrypted_visit
            expect(response).to redirect_to(deferred_show_confirmation_path(visit_id: visit.visit_id))
            expect(ActionMailer::Base.deliveries.map(&:subject)).to eq(
              [
                "Visit cannot take place: your visit for 7 July 2013 could not be booked",
                "COPY of booking rejection for Jimmy Harris"
              ]
            )
          end
        end

        context "when a form is submitted without a slot" do
          it "sends out an e-mail and records a metric" do
            expect(mock_metrics_logger).
              to receive(:record_booking_rejection).
              with(same_visit(visit), Confirmation::NO_SLOT_AVAILABLE)
          end

          after do
            post :create,
              confirmation: {
                outcome: Confirmation::NO_SLOT_AVAILABLE,
                canned_response: true
              },
              state: encrypted_visit
            expect(response).to redirect_to(deferred_show_confirmation_path(visit_id: visit.visit_id))
            expect(ActionMailer::Base.deliveries.map(&:subject)).to eq(
              [
                "Visit cannot take place: your visit for 7 July 2013 could not be booked",
                "COPY of booking rejection for Jimmy Harris"
              ]
            )
          end
        end

        context "when an incomplete form is submitted" do
          it "redirects back to the new action" do
            post :create,
              confirmation: {
                outcome: 'lol', canned_response: true
              },
              state: encrypted_visit
            expect(response).to render_template('confirmations/new')
          end
        end

        context "when the thank you screen is accessed" do
          it "resets the session" do
            expect(controller).to receive(:reset_session).once
            get :show, visit_id: visit.visit_id
            expect(response).to render_template('confirmations/show')
          end
        end

      end
    end
  end

  context "IP restrictions" do
    it "denies all other requests" do
      allow(Rails.configuration).to receive(:permitted_ips_for_confirmations).and_return(['127.0.0.2'])
      expect {
        get :new
      }.to raise_error(ActionController::RoutingError)
    end
  end
end
