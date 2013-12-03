require 'spec_helper'

describe Feedback do
  it "validates required attributes" do
    subject.should_not be_valid

    subject.text = "test"
    subject.should_not be_valid

    subject.email = "email@lol.biz.info"
    subject.should_not be_valid

    subject.referrer = "referrer"
    subject.should be_valid
  end
end
