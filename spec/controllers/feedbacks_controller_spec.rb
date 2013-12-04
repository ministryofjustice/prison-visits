require 'spec_helper'

describe FeedbacksController do
  it "displays feedback form" do
    get :new
    response.should render_template('feedbacks/new')
    response.should be_success
  end

  it "redirects to show page on successful feedback submission" do
    ZendeskHelper.should_receive(:send_to_zendesk).once
    post :create, feedback: { email: 'test@lol.biz.info', text: 'feedback', referrer: 'ref' }
    response.should redirect_to feedback_path
  end

  it "displays the form again if a submission was unsuccessful" do
    post :create, feedback: { email: 'test@lol.biz.info' }
    response.should render_template('feedbacks/new')
    response.should be_success
  end
end
