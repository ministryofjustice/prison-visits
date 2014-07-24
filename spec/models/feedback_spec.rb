require 'spec_helper'

describe Feedback do
  before :each do
    EmailValidator.any_instance.stub(:has_mx_records).with('maildrop.dsd.io').and_return(true)
  end

  it "validates required attributes" do
    subject.should_not be_valid

    subject.text = "test"
    subject.should_not be_valid

    subject.user_agent = 'Mozilla'
    subject.should_not be_valid

    subject.email = "broken email"
    subject.should_not be_valid

    subject.referrer = "referrer"
    subject.should_not be_valid

    subject.email = "test@maildrop.dsd.io"
    subject.should be_valid

    subject.email = nil
    subject.should be_valid
  end
end
