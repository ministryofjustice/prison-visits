require 'rails_helper'

RSpec.describe Feedback do
  before :each do
    allow_any_instance_of(EmailValidator).to receive(:validate_address_domain).and_return(false)
    allow_any_instance_of(EmailValidator).to receive(:validate_spam_reporter).and_return(false)
    allow_any_instance_of(EmailValidator).to receive(:validate_bad_domain).and_return(false)
    allow_any_instance_of(EmailValidator).to receive(:validate_dns_records).and_return(false)
    allow_any_instance_of(EmailValidator).to receive(:validate_bounced).and_return(false)
  end

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
