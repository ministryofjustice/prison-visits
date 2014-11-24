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

  let! :subject do
    PrisonMailer
  end

  let :confirmation_with_slot do
    Confirmation.new(vo_number: '5551234', outcome: 'slot_0')
  end

  let :confirmation_without_slot do
    Confirmation.new(vo_number: '5551234', outcome: Confirmation::NO_SLOT_AVAILABLE)
  end

  let :confirmation_not_on_contact_list do
    Confirmation.new(outcome: Confirmation::NOT_ON_CONTACT_LIST)
  end

  let :confirmation_no_vos_left do
    Confirmation.new(renew_vo: '2014-09-01', outcome: Confirmation::NO_VOS_LEFT)
  end

  context "always" do
    it "sends an e-mail with the prisoner name in the subject" do
      subject.booking_request_email(sample_visit, "token").subject.should == 'Visit request for Jimmy Harris on Sunday 7 July'
    end

    it "sends an e-mail with a long link to the confirmation page" do
      email = subject.booking_request_email(sample_visit, "token")
      email.body.should =~ /confirmation\/new\?state=token/
      email.body.should =~ /https:\/\/localhost/
      email.content_type.should == 'text/html; charset=UTF-8'
    end

    it "sends a booking receipt to a prison to create an audit trail" do
      subject.booking_receipt_email(sample_visit, confirmation_with_slot).tap do |email|
        email.subject.should == "COPY of booking confirmation for Jimmy Harris"
        email.body.should include('Mark')
        email.body.should include('5551234')
      end

      [confirmation_without_slot, confirmation_not_on_contact_list, confirmation_no_vos_left].each do |confirmation|
        subject.booking_receipt_email(sample_visit, confirmation).tap do |email|
          email.subject.should == "COPY of booking rejection for Jimmy Harris"
          email.body.should include('Mark')
        end
      end
    end

    it "sends an e-mail to rochester functional mailbox" do
      sample_visit.tap do |visit|
        visit.prisoner.prison_name = 'Rochester'
        subject.booking_request_email(visit, "token").to.should == ['pvb.rochester@maildrop.dsd.io']
      end
    end

    it "sends an e-mail with a link over https" do
      subject.booking_request_email(sample_visit, "token").body.should =~ /https:\/\/localhost/
    end

    it "uses its own configuration (GSI)" do
      subject.smtp_settings.should_not === ActionMailer::Base.smtp_settings
    end
  end
end
