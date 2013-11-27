require 'spec_helper'

describe BookingRequest do
  let! :subject do
    BookingRequest
  end

  let! :sample_visit do
    Visit.new.tap do |v|
      v.slots = []
      v.prisoner = Prisoner.new.tap do |p|
        p.date_of_birth = '2013-06-30'
      end
      v.visitors = [Visitor.new(email: 'sample@email.lol', date_of_birth: Time.now)]
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
    
    it "sends an e-mail to durham functional mailbox" do
      sample_visit.tap do |visit|
        visit.prisoner.prison_name = 'Durham'
        subject.request_email(visit).to.should == ['socialvisits.durham@hmps.gsi.gov.uk']
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