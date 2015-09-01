require 'rails_helper'

RSpec.describe Feedback do
  it "validates required attributes" do
    subject.user_agent = 'Mozilla'
    expect(subject).not_to be_valid

    subject.email = "broken email"
    expect(subject).not_to be_valid

    subject.text = "test"
    expect(subject).not_to be_valid

    subject.email = "test@maildrop.dsd.io"
    expect(subject).to be_valid

    subject.email = nil
    expect(subject).to be_valid
  end
end
