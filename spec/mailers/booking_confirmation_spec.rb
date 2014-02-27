require 'spec_helper'

describe BookingConfirmation do
  let! :subject do
    BookingConfirmation
  end

  let! :sample_visit do
    Visit.new.tap do |v|
      v.slots = [Slot.new(date: '2013-12-06', times: '0945-1115')]
      v.prisoner = Prisoner.new.tap do |p|
        p.date_of_birth = '2013-06-30'
        p.prison_name = 'Rochester'
      end
      v.visitors = [Visitor.new.tap do |v|
        v.email = 'sample@email.lol'
        v.date_of_birth = '1975-01-01'
      end]
    end
  end

  context "always" do
    it "sends out an e-mail with a date in the subject" do
      subject.confirmation_email(sample_visit).subject.should == "Your visit request for 6 December 2013"
    end
  end

  context "in production" do
    before :each do
      BookingConfirmation.any_instance.stub(:production?).and_return(true)
      BookingConfirmation.any_instance.stub(:sender).and_return('no-reply@pvb.local')
    end

    it "sends an e-mail to the person who requested a booking" do
      email = subject.confirmation_email(sample_visit)
      email.to.should == ['sample@email.lol'] 
      email.from.should == ['socialvisits.rochester@hmps.gsi.gov.uk']
      email.reply_to.should == ['socialvisits.rochester@hmps.gsi.gov.uk']
      email.sender.should == 'no-reply@pvb.local'
    end
  end

  context "in staging or any other environment" do
    before :each do
      BookingConfirmation.any_instance.stub(:production?).and_return(false)
    end

    it "sends an email to a google groups address" do
      subject.confirmation_email(sample_visit).to.should == ['pvb-email-test@googlegroups.com']
    end
  end
end
