require 'spec_helper'

describe FeedbacksController do
  before :each do
    ActionMailer::Base.deliveries.clear
  end

  it "displays feedback form" do
    get :new
    response.should render_template('feedbacks/new')
    response.should be_success
  end

  it "redirects to show page on successful feedback submission" do
    FeedbackNotification.should_receive(:new_message).once.and_call_original
    ZendeskHelper.should_receive(:send_to_zendesk).once
    expect {
      post :create, feedback: { email: 'test@lol.biz.info', text: 'feedback', referrer: 'ref' }
      response.should redirect_to feedback_path
    }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it "displays the form again if a submission was unsuccessful" do
    post :create, feedback: { email: 'test@lol.biz.info' }
    response.should render_template('feedbacks/new')
    response.should be_success
  end
end
