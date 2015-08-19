require 'rails_helper'

RSpec.describe FeedbacksController, type: :controller do
  include ActiveJobHelper

  before do
    ActionMailer::Base.deliveries.clear
    allow_any_instance_of(EmailValidator).to receive(:validate)
    allow(ZendeskHelper).to receive(:send_to_zendesk)
  end

  context 'new' do
    it 'responds with success' do
      get :new
      expect(response).to be_success
    end

    it 'displays feedback form' do
      get :new
      expect(response).to render_template('feedbacks/new')
    end
  end

  context 'create' do
    context 'with a successful feedback submission' do
      let(:feedback_params) {
        { email: 'test@maildrop.dsd.io', text: 'feedback', referrer: 'ref' }
      }

      it 'redirects to show page' do
        post :create, feedback: feedback_params
        expect(response).to redirect_to feedback_path
      end

      it 'sends to ZenDesk' do
        expect(ZendeskHelper).to receive(:send_to_zendesk).once do |feedback|
          expect(feedback.email).to eq('test@maildrop.dsd.io')
          expect(feedback.text).to eq('feedback')
        end
        post :create, feedback: feedback_params
      end

      it 'sends an email' do
        expect {
          post :create, feedback: feedback_params
        }.to change { ActionMailer::Base.deliveries.size }.by(1)
      end
    end

    context 'with no email address entered' do
      let(:feedback_params) {
        { email: '', text: 'feedback', referrer: 'ref' }
      }

      it 'redirects to feedback page' do
        post :create, feedback: feedback_params
        expect(response).to redirect_to feedback_path
      end

      it 'does not send to ZenDesk' do
        expect(ZendeskHelper).to receive(:send_to_zendesk).never
        post :create, feedback: feedback_params
      end

      it 'sends an email' do
        expect {
          post :create, feedback: feedback_params
        }.to change { ActionMailer::Base.deliveries.size }.by(1)
      end
    end

    context 'with no text entered' do
      let(:feedback_params) {
        { email: 'test@maildrop.dsd.io', text: '', referrer: 'ref' }
      }

      it 'responds with success' do
        post :create, feedback: feedback_params
        expect(response).to be_success
      end

      it 'does not send to ZenDesk' do
        expect(ZendeskHelper).to receive(:send_to_zendesk).never
        post :create, feedback: feedback_params
      end

      it 'does not send an email' do
        expect {
          post :create, feedback: feedback_params
        }.not_to change { ActionMailer::Base.deliveries.size }
      end

      it 're-renders the feedback template' do
        post :create, feedback: feedback_params
        expect(response).to render_template('feedbacks/new')
      end
    end

    context 'when an active booking session is present' do
      let(:feedback_params) {
        {
          email: 'test@maildrop.dsd.io',
          text: 'feedback',
          referrer: 'ref'
        }
      }

      before do
        session[:visit] =
          Visit.new(prisoner: Prisoner.new(prison_name: 'Rochester'))
      end

      it 'extracts the prison name from the session' do
        expect(ZendeskHelper).to receive(:send_to_zendesk) do |feedback|
          expect(feedback.prison).to eq('Rochester')
        end
        post :create, feedback: feedback_params
      end
    end
  end
end
