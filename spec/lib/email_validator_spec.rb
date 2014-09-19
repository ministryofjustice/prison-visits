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

  end

  it "allows correct e-mail addresses" do
    subject.should_receive(:has_mx_records).and_return(true)
    expect {
      model.email = 'feedback@lol.biz.info'
      subject.validate(model)
    }.not_to change { model.errors.empty? }
  end

  context "DNS checks for domain" do
    it "checks for the existence of an MX record for the domain" do
      Resolv::DNS.any_instance.should_receive(:getresources).and_return([])
      expect {
        model.email = 'test@gmail.co.uk'
        subject.validate(model)
      }.to change { model.errors.empty? }
    end

    it "doesn't return an error when the MX lookup timed out" do
      Resolv::DNS.any_instance.should_receive(:getresources).and_raise(Resolv::ResolvTimeout)
      expect {
        model.email = 'test@irrelevant.com'
        subject.validate(model)
      }.not_to change { model.errors.empty? }
    end
  end
end
