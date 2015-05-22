require 'spec_helper'

describe Instant::Visitor do
  before :each do
    allow_any_instance_of(EmailValidator).to receive(:validate_dns_records)
    allow_any_instance_of(EmailValidator).to receive(:validate_spam_reporter)
    allow_any_instance_of(EmailValidator).to receive(:validate_bounced)
  end

  let :visitor do
    subject.tap do |v|
      v.first_name = 'Otto'
      v.last_name = 'Fibonacci'
      v.email = 'test@maildrop.dsd.io'
      v.date_of_birth = 30.years.ago
    end
  end

  it 'generates an initial from the last name' do
    expect(visitor.last_initial).to eq('F')
  end

  it_behaves_like 'a visitor'

  it "validates the first visitor as a lead visitor" do
    subject.tap do |v|
      v.index = 0

      v.first_name = 'Jimmy'
      expect(v).not_to be_valid

      v.last_name = 'Harris'
      expect(v).not_to be_valid

      v.date_of_birth = Date.parse "1986-04-20"
      expect(v).not_to be_valid

      v.email = 'jimmy@maildrop.dsd.io'
      expect(v).to be_valid
    end
  end
end
