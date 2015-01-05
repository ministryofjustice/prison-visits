require 'spec_helper'
require 'email_validator'

describe EmailValidator do
  let :subject do
    EmailValidator.new
  end

  let! :model do
    Visitor.new
  end

  context "with bad e-mail address" do
    it "doesn't allow for a borked e-mail address" do
      expect {
        model.email = '@bad-email'
        subject.validate(model)
      }.to change { model.errors.empty? }
    end

    it "doesn't allow an empty e-mail address" do
      expect {
        model.email = ''
        subject.validate(model)
      }.to change { model.errors.empty? }
    end

    it "doesn't allow an address with a local part only" do
      expect {
        model.email = 'jimmy.harris'
        subject.validate(model)
      }.to change { model.errors.empty? }
    end

    it "doesn't allow domains with a dot at the end" do
      expect {
        model.email = 'feedback@domain.com.'
        subject.validate(model)
      }.to change { model.errors.empty? }
    end

    it "doesn't allow domains with a dot at the beginning" do
      expect {
        model.email = 'feedback@.domain.com'
        subject.validate(model)
      }.to change { model.errors.empty? }
    end

    EmailValidator::BAD_DOMAINS.each do |domain|
      it "doesn't allow domains that are known to be bad: #{domain}" do
        expect {
          model.email = "feedback@#{domain}"
          subject.validate(model)
        }.to change { model.errors.empty? }
      end
    end
  end

  it "allows correct e-mail addresses" do
    subject.should_receive(:validate_dns_records).and_return(false)
    subject.should_receive(:validate_spam_reporter).and_return(false)
    expect {
      model.email = 'feedback@lol.biz.info'
      subject.validate(model)
    }.not_to change { model.errors.empty? }
  end

  context "DNS checks for domain" do
    it "checks for the existence of an MX record for the domain" do
      Resolv::DNS.any_instance.should_receive(:getresource).and_raise(Resolv::ResolvError)
      expect {
        model.email = 'test@gmail.co.uk'
        subject.validate(model)
      }.to change { model.errors.empty? }
    end

    it "doesn't return an error when the MX lookup timed out" do
      Resolv::DNS.any_instance.should_receive(:getresource).and_raise(Resolv::ResolvTimeout)
      subject.should_receive(:validate_spam_reporter).and_return(false)
      expect {
        model.email = 'test@irrelevant.com'
        subject.validate(model)
      }.not_to change { model.errors.empty? }
    end
  end

  context "spam reporters" do
    it "prevents validation on an e-mail address marked as a spam reporter in sendgrid" do
      subject.should_receive(:validate_dns_records).and_return(false)
      SendgridHelper.should_receive(:spam_reported?).and_return(true)
      expect {
        model.email = 'test@irrelevant.com'
        subject.validate(model)
      }.to change { model.errors.empty? }
      model.errors.first.should == [:email, "cannot receive messages from this system"]
    end
  end
end
