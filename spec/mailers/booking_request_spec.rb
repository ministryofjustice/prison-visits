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
      BookingRequest.any_instance.should_receive(:production?).and_return(true)
    end

    it "sends an e-mail to rochester functional mailbox" do
      sample_visit.tap do |visit|
        visit.prisoner.prison_name = 'Rochester'
        subject.request_email(visit).to.should == ['socialvisits.rochester@hmps.gsi.gov.uk']
      end
    end
  end

  context "in staging or any other environment" do
    before :each do
      BookingRequest.any_instance.should_receive(:production?).and_return(false)
    end
    
    it "sends an email to a google groups address" do
      sample_visit.tap do |visit|
        subject.request_email(visit).to.should == ['pvb-email-test@googlegroups.com']
      end
    end
  end
end
