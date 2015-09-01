require 'rails_helper'
require 'email_validator'

RSpec.describe EmailValidator do
  subject { described_class.new(address) }

  before do
    allow_any_instance_of(Resolv::DNS).
      to receive(:getresource).and_return(true)
  end

  shared_examples 'a valid address' do
    it { is_expected.to be_valid }

    it 'has no error' do
      expect(subject.error).to be_nil
    end
  end

  shared_examples 'an invalid address' do |sym|
    it { is_expected.not_to be_valid }

    it "has the #{sym} error" do
      expect(subject.error).to eq(sym)
    end
  end

  context 'with invalid address' do
    context 'with empty string' do
      let(:address) { '' }
      it_behaves_like 'an invalid address', :malformed
    end

    context 'with domain only' do
      let(:address) { '@test.example.com' }
      it_behaves_like 'an invalid address', :unparseable
    end

    context 'with local part only' do
      let(:address) { 'jimmy.harris' }
      it_behaves_like 'an invalid address', :malformed
    end

    context 'with dot at start of domain' do
      let(:address) { 'user@.test.example.com' }
      it_behaves_like 'an invalid address', :domain_dot
    end

    context 'with dot at end of domain' do
      let(:address) { 'user@test.example.com.' }
      it_behaves_like 'an invalid address', :unparseable
    end

    context 'with known bad domain' do
      let(:address) { 'user@hitmail.com' }
      it_behaves_like 'an invalid address', :bad_domain
    end
  end

  context 'with valid address' do
    let(:address) { 'user@test.example.com' }

    it_behaves_like 'a valid address'

    it 'checks MX record only once' do
      expect_any_instance_of(Resolv::DNS).
        to receive(:getresource).once.and_return(true)

      2.times do
        subject.valid?
      end
    end

    it 'checks Sendgrid only once' do
      expect(SendgridHelper).to receive(:spam_reported?).once.and_return(false)
      expect(SendgridHelper).to receive(:bounced?).once.and_return(false)

      2.times do
        subject.valid?
      end
    end

    context 'with no MX record' do
      before do
        allow_any_instance_of(Resolv::DNS).
          to receive(:getresource).and_raise(Resolv::ResolvError)
      end

      it_behaves_like 'an invalid address', :no_mx_record
    end

    context 'when MX lookup times out' do
      before do
        allow_any_instance_of(Resolv::DNS).
          to receive(:getresource).and_raise(Resolv::ResolvTimeout)
      end

      it_behaves_like 'a valid address'
    end

    context 'when spam is reported' do
      before do
        allow(SendgridHelper).to receive(:spam_reported?).and_return(true)
      end

      it_behaves_like 'an invalid address', :spam_reported
    end

    context 'when bounce is reported' do
      before do
        allow(SendgridHelper).to receive(:bounced?).and_return(true)
      end

      it_behaves_like 'an invalid address', :bounced
    end
  end
end
