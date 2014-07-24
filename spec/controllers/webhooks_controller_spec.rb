require 'spec_helper'

describe WebhooksController do
  let :charsets do
    { from: 'utf-8', to: 'utf-8', subject: 'utf-8', text: 'utf-8' }.to_json
  end

  let :noreply_address do
    'no-reply@example.com'
  end
  
  let :email_from_prison do
    {
      from: "HMP Hull <hull@hmps.gsi.gov.uk>",
      to: noreply_address,
      subject: "A visit",
      text: "Some text",
      charsets: charsets
    }
  end

  let :email_from_visitor do
    {
      from: "Jimmy Harris <jimmy@example.com>",
      to: noreply_address,
      subject: "A visit",
      text: "Some text",
      charsets: charsets
    }
  end

  let :email_gibberish do
    {
    }
  end

  let :email_to_unknown do
    {
      from: "unknown@example.com",
      to: "unknown@example.com",
      subject: "A subject",
      text: "Some text",
      charsets: charsets
    }
  end

  def authorized(email)
    email.merge(auth: 'irrelevant')
  end

  def bad_encoding(email)
    email.merge(charsets: { from: 'utf-8', to: 'utf-8', subject: 'utf-8', text: 'unicode-1-1-utf-7' }.to_json)

  end

  before :each do
    ActionMailer::Base.deliveries.clear
  end

  context "when a valid e-mail webhook comes in" do
    before :each do
      subject.should_receive(:authorized?).and_return(true)
    end

    context "from the visitor to the no-reply address" do
      it "sends a reminder that the amilbox is unattended to the visitor" do
        post :email, authorized(email_from_visitor)
        response.should be_successful
        ActionMailer::Base.deliveries.size.should == 1
      end
    end

    context "from the prison to the no-reply address" do
      it "sends a reminder that the mailbox is unattended to the prison" do
        post :email, authorized(email_from_prison)
        response.should be_successful
        ActionMailer::Base.deliveries.size.should == 1
      end
    end
  end

  context "when an invalid e-mail webhook comes in" do
    before :each do
      subject.should_receive(:authorized?).and_return(true)
    end

    after :each do
      ActionMailer::Base.deliveries.should == []
    end

    context "on bad encoding" do
      it "discards the email" do
        post :email, authorized(bad_encoding(email_from_prison))
        response.should be_successful
      end
    end

    context "on bad data" do
      it "discards the email and returns OK" do
        post :email, authorized(email_gibberish)
        response.should be_successful
      end
    end

    context "on unknown recipient" do
      it "discards the email and returns OK" do
        post :email, authorized(email_to_unknown)
        response.should be_successful
      end
    end

    context "on gsi service being unavailable" do
      it "tells sendgrid that the email could not be enqueued" do
        PrisonMailer.any_instance.should_receive(:autorespond).and_raise(exception = Net::SMTPFatalError.new)
        expect {
          post :email, authorized(email_from_prison)
        }.to raise_error(exception)
      end
    end
  end

  context "when an unauthenticated webhook comes in" do
    before :each do
      controller.should_receive(:authorized?).and_return(false)
    end

    it "returns a 403 unauthorized status" do
      post :email, authorized(email_from_prison)
      response.status.should == 403
    end
  end
end
