require 'spec_helper'

describe BookingRequest do
  let! :subject do
    BookingRequest
  end

  let! :sample_visit do
    Visit.new.tap do |v|
      v.slots = []
      v.prisoner = Prisoner.new.tap do |p|
        p.date_of_birth = Date.new(2013, 6, 30)
        p.prison_name = 'Rochester'
        p.first_name = 'Jimmy'
        p.last_name = 'Fingers'
      end
      v.visitors = [Visitor.new(email: 'sample@email.lol', date_of_birth: Date.new(1918, 11, 11))]
    end
  end

  it "has its own SMTP configuration" do
    subject.smtp_settings.should_not == ActionMailer::Base.smtp_settings
  end

  context "always" do
    it "sends an e-mail with the prisoner name in the subject" do
      subject.request_email(sample_visit).subject.should == 'Visit request for Jimmy Fingers'
    end
  end

  context "in production" do
    before :each do
      BookingRequest.any_instance.stub(:production?).and_return(true)
      BookingRequest.any_instance.stub(:sender).and_return('no-reply@pvb.local')
    end

    it "sends an e-mail to rochester functional mailbox" do
      sample_visit.tap do |visit|
        visit.prisoner.prison_name = 'Rochester'
        email = subject.request_email(visit)
        email.to.should == ['socialvisits.rochester@maildrop.dsd.io']
        email.from.should == ['sample@email.lol']
        email.reply_to.should == ['sample@email.lol']
        email.sender.should == 'no-reply@pvb.local'
      end
    end
  end

  context "in staging or any other environment" do
    before :each do
      BookingRequest.any_instance.stub(:production?).and_return(false)
    end
    
    it "sends an email to a google groups address" do
      sample_visit.tap do |visit|
        subject.request_email(visit).to.should == ['pvb-email-test@googlegroups.com']
      end
    end
  end
end
