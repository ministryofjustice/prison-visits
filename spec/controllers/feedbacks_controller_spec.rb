require 'spec_helper'

describe FeedbacksController do
  before :each do
    ActionMailer::Base.deliveries.clear
    allow_any_instance_of(EmailValidator).to receive(:validate)
  end

  it "displays feedback form" do
    get :new
    expect(response).to render_template('feedbacks/new')
    expect(response).to be_success
  end

  it "redirects to show page on successful feedback submission" do
    expect(FeedbackMailer).to receive(:new_feedback).once.and_call_original
    expect(ZendeskHelper).to receive(:send_to_zendesk).once
    expect {
      post :create, feedback: { email: 'test@maildrop.dsd.io', text: 'feedback', referrer: 'ref' }
      expect(response).to redirect_to feedback_path
    }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it "redirects to show page on successful feedback submission when no email address is entered" do
    expect(FeedbackMailer).to receive(:new_feedback).once.and_call_original
    expect(ZendeskHelper).to receive(:send_to_zendesk).never
    expect {
      post :create, feedback: { email: '', text: 'feedback', referrer: 'ref' }
      expect(response).to redirect_to feedback_path
    }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it "displays the form again if a submission was unsuccessful" do
    post :create, feedback: { email: 'test@maildrop.dsd.io' }
    expect(response).to render_template('feedbacks/new')
    expect(response).to be_success
  end

  context "there is an active booking session present" do
    before :each do
      session[:visit] = Visit.new(prisoner: Prisoner.new(prison_name: 'Rochester'))
    end

    it "extracts the prison name from the session" do
      expect(ZendeskHelper).to receive(:send_to_zendesk).once { |feedback|
        expect(feedback.prison).to eq('Rochester')
      }
      post :create, feedback: { email: 'test@maildrop.dsd.io', text: 'feedback', referrer: 'ref', prison: 'Rochester' }
      expect(response).to redirect_to feedback_path
    end
  end
end
