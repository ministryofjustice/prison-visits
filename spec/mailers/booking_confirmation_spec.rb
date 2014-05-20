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
    before :each do
      BookingConfirmation.any_instance.stub(:sender).and_return('no-reply@pvb.local')
    end

    it "sends out an e-mail with a date in the subject" do
      subject.confirmation_email(sample_visit).subject.should == "You have requested a visit for 6 December 2013"
    end

    it "sends an e-mail to the person who requested a booking" do
      email = subject.confirmation_email(sample_visit)
      email.to.should == ['sample@email.lol'] 
      email.from.should == ['pvb.socialvisits.rochester@maildrop.dsd.io']
      email.reply_to.should == ['pvb.socialvisits.rochester@maildrop.dsd.io']
      email.sender.should == 'no-reply@pvb.local'
    end
  end
end
