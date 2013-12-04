require 'spec_helper'
require 'email_validator'

describe EmailValidator do
  let :subject do
    EmailValidator.new({attributes: [:email]})
  end

  let! :model do
    Visitor.new
  end

  it "doesn't allow for a borked e-mail address" do
    expect {
      subject.validate_each(model, :email, '@bad-email')
    }.to change { model.errors.empty? }
  end

  it "allows correct e-mail addresses" do
    expect {
      subject.validate_each(model, :email, 'feedback@lol.biz.info')
    }.not_to change { model.errors.empty? }
  end
end
