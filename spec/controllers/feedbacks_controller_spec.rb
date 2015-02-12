require 'spec_helper'

describe FeedbacksController do
  before :each do
    ActionMailer::Base.deliveries.clear
    EmailValidator.any_instance.stub(:validate)
  end

  it "displays feedback form" do
    get :new
    response.should render_template('feedbacks/new')
    response.should be_success
  end

  it "redirects to show page on successful feedback submission" do
    FeedbackMailer.should_receive(:new_feedback).once.and_call_original
    ZendeskHelper.should_receive(:send_to_zendesk).once
    expect {
      post :create, feedback: { email: 'test@maildrop.dsd.io', text: 'feedback', referrer: 'ref' }
      response.should redirect_to feedback_path
    }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it "redirects to show page on successful feedback submission when no email address is entered" do
    FeedbackMailer.should_receive(:new_feedback).once.and_call_original
    ZendeskHelper.should_receive(:send_to_zendesk).never
    expect {
      post :create, feedback: { email: '', text: 'feedback', referrer: 'ref' }
      response.should redirect_to feedback_path
    }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it "displays the form again if a submission was unsuccessful" do
    post :create, feedback: { email: 'test@maildrop.dsd.io' }
    response.should render_template('feedbacks/new')
    response.should be_success
  end

  context "there is an active booking session present" do
    before :each do
      session[:visit] = Visit.new(prisoner: Prisoner.new(prison_name: 'Rochester'))
    end

    it "extracts the prison name from the session" do
      ZendeskHelper.should_receive(:send_to_zendesk).once.with do |feedback|
        feedback.prison.should == 'Rochester'
      end
      expect {
        post :create, feedback: { email: 'test@maildrop.dsd.io', text: 'feedback', referrer: 'ref', prison: 'Rochester' }
        response.should redirect_to feedback_path
      }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
