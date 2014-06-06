require "spec_helper"

describe VisitorMailer do
  before :each do
    ActionMailer::Base.deliveries.clear
    VisitorMailer.any_instance.stub(:smtp_domain).and_return('example.com')
  end

  let :email do
    ParsedEmail.parse({
        from: "visitor@example.com",
        to: 'test@example.com',
        text: "some text",
        charsets: {to: "UTF-8", html: "utf-8", subject: "UTF-8", from: "UTF-8", text: "utf-8"}.to_json,
        subject: "important email",
    })
  end

  it "relays e-mails via sendgrid" do
    VisitorMailer.smtp_settings.should == ActionMailer::Base.smtp_settings
  end

  it "delivers an automated response" do
    expect {
      VisitorMailer.autorespond(email).tap do |m|
        m.from.should == ['no-reply@example.com']
        m.to.should == ['visitor@example.com']
      end.deliver
    }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  let! :subject do
    VisitorMailer
  end

  let :confirmation do
    Confirmation.new(message: 'A message', outcome: 'slot_0')
  end

  let :confirmation_no_slot_available do
    Confirmation.new(message: 'A message', outcome: 'no_slot_available')
  end

  let :confirmation_not_on_contact_list do
    Confirmation.new(message: 'A message', outcome: 'not_on_contact_list')
  end

  let :noreply_address do
    
  end

  context "always" do
    context "booking is successful" do
      it "sends out an e-mail" do
        email = subject.booking_confirmation_email(sample_visit, confirmation)
        email.subject.should == "Your visit for 7 July 2013 has been confirmed."
        email.from.should == ["no-reply@example.com"]
        email.reply_to.should == ["pvb.socialvisits.rochester@maildrop.dsd.io"]
        email.to.should == ["visitor@example.com"]

        email.body.raw_source.should include("email: pvb.socialvisits.rochester@maildrop.dsd.io")
        email.body.raw_source.should include("phone: 01634 803100")
        email.body.raw_source.should_not include("Jimmy Fingers")
      end
    end

    context "booking is unsuccessful because of a slot not being available" do
      it "sends out an e-mail with a date in the subject" do
        email = subject.booking_rejection_email(sample_visit, confirmation_no_slot_available)
        email.subject.should == "Your visit for 7 July 2013 could not be booked."
        email.from.should == ["no-reply@example.com"]
        email.reply_to.should == ["pvb.socialvisits.rochester@maildrop.dsd.io"]
        email.to.should == ["visitor@example.com"]

        email.body.raw_source.should include('http://www.justice.gov.uk/contacts/prison-finder/rochester')
        email.body.raw_source.should include("01634 803100")
        email.body.raw_source.should_not include("Jimmy Fingers")
      end
    end

    context "booking is unsuccessful because of a visitor not being on a contact list" do
      it "sends out an e-mail with a date in the subject" do
        email = subject.booking_rejection_email(sample_visit, confirmation_not_on_contact_list)
        email.subject.should == "Your visit for 7 July 2013 could not be booked."
        email.from.should == ["no-reply@example.com"]
        email.reply_to.should == ["pvb.socialvisits.rochester@maildrop.dsd.io"]
        email.to.should == ["visitor@example.com"]

        email.body.raw_source.should include('http://www.justice.gov.uk/contacts/prison-finder/rochester')
        email.body.raw_source.should include("01634 803100")
        email.body.raw_source.should_not include("Jimmy Fingers")
      end
    end

    context "booking receipt sent" do
      it "sends out an e-mail with a date in the subject" do
        email = subject.booking_receipt_email(sample_visit)
        email.subject.should == "Your visit for 7 July 2013 will be processed soon."
        email.from.should == ["no-reply@example.com"]
        email.to.should == ['visitor@example.com']
        email.body.raw_source.should_not include("Jimmy Fingers")
      end
    end

    it "sends an e-mail to the person who requested a booking" do
      subject.booking_confirmation_email(sample_visit, confirmation).to.should == ['visitor@example.com']
    end
  end
end
