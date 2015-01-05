require 'spec_helper'

describe Feedback do
  before :each do
    EmailValidator.any_instance.stub(:validate_address_domain).and_return(false)
    EmailValidator.any_instance.stub(:validate_spam_reporter).and_return(false)
    EmailValidator.any_instance.stub(:validate_bad_domain).and_return(false)
    EmailValidator.any_instance.stub(:validate_dns_records).and_return(false)
  end

  it "validates required attributes" do
    subject.user_agent = 'Mozilla'
    subject.should_not be_valid

    subject.email = "broken email"
    subject.should_not be_valid

    subject.text = "test"
    subject.should_not be_valid

    subject.email = "test@maildrop.dsd.io"
    subject.should be_valid

    subject.email = nil
    subject.should be_valid
  end
end
