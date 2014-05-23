require "spec_helper"

describe PrisonMailer do
  before :each do
    ActionMailer::Base.deliveries.clear
    PrisonMailer.any_instance.stub(:smtp_domain).and_return('example.com')
  end

  let :email do
    ParsedEmail.parse({
        from: "nonexistent@hmps.gsi.gov.uk",
        to: 'test@example.com',
        text: "some text",
        charsets: {to: "UTF-8", html: "utf-8", subject: "UTF-8", from: "UTF-8", text: "utf-8"}.to_json,
        subject: "important email",
    })
  end

  it "relays e-mails via GSI" do
    PrisonMailer.smtp_settings.should_not == ActionMailer::Base.smtp_settings
  end

  it "delivers an automated response" do
    expect {
      PrisonMailer.autorespond(email).tap do |m|
        m.from.should == ['no-reply@example.com']
        m.to.should == ['nonexistent@hmps.gsi.gov.uk']
      end.deliver
    }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end
end
