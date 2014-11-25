# -*- coding: utf-8 -*-
require "spec_helper"

describe VisitorMailer do
  before :each do
    ActionMailer::Base.deliveries.clear
    VisitorMailer.any_instance.stub(:smtp_domain).and_return('example.com')
    Timecop.freeze(Time.local(2013, 7, 4))
  end

  after :each do
    Timecop.return
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
        m[:from].should == noreply_address
        m[:to].should == visitor_address
      end.deliver
    }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  let! :subject do
    VisitorMailer
  end

  let :confirmation do
    Confirmation.new(vo_number: '5551234', outcome: 'slot_0')
  end

  let :confirmation_unlisted_visitors do
    Confirmation.new(vo_number: '5551234', outcome: 'slot_0', visitor_not_listed: true, unlisted_visitors: ['Joan;Harris'])
  end

  let :confirmation_banned_visitors do
    Confirmation.new(vo_number: '5551234', outcome: 'slot_0', visitor_banned: true, banned_visitors: ['Joan;Harris'])
  end

  let :confirmation_no_slot_available do
    Confirmation.new(vo_number: '5551234', outcome: Confirmation::NO_SLOT_AVAILABLE)
  end

  let :confirmation_not_on_contact_list do
    Confirmation.new(outcome: Confirmation::NOT_ON_CONTACT_LIST)
  end

  let :rejection_prisoner_incorrect do
    Confirmation.new(outcome: Confirmation::PRISONER_INCORRECT)
  end

  let :rejection_prisoner_not_present do
    Confirmation.new(outcome: Confirmation::PRISONER_NOT_PRESENT)
  end

  let :rejection_visitor_not_listed do
    Confirmation.new(visitor_not_listed: true, unlisted_visitors: ['Joan;Harris'])
  end

  let :rejection_visitor_banned do
    Confirmation.new(visitor_banned: true, banned_visitors: ['Joan;Harris'])
  end

  let :confirmation_no_vos_left do
    Confirmation.new(renew_vo: '2014-09-01', outcome: Confirmation::NO_VOS_LEFT)
  end

  let :noreply_address do
    Mail::Field.new('from', "Prison Visits Booking <no-reply@example.com> (Unattended)")
  end

  let :visitor_address do
    Mail::Field.new('to', "Mark Harris <visitor@example.com>")
  end

  let :prison_address do
    Mail::Field.new('reply-to', "pvb.rochester@maildrop.dsd.io")
  end

  context "always" do
    context "booking is successful" do
      it "sends out an e-mail" do
        email = subject.booking_confirmation_email(sample_visit, confirmation)
        email.subject.should == "Visit confirmed: your visit for 7 July 2013 has been confirmed"

        email[:from].should == noreply_address
        email[:reply_to].should == prison_address
        email[:to].should == visitor_address

        email.body.raw_source.should include("email: pvb.rochester@maildrop.dsd.io")
        email.body.raw_source.should include("phone: 01634 803100")
        email.body.raw_source.should_not include("Jimmy Harris")
        email.body.raw_source.should include('5551234')
      end

      it "sends out an e-mail with the list of visitors not on the approved visitor list" do
        email = subject.booking_confirmation_email(sample_visit, confirmation_unlisted_visitors)
        email.subject.should == "Visit confirmed: your visit for 7 July 2013 has been confirmed"

        email[:from].should == noreply_address
        email[:reply_to].should == prison_address
        email[:to].should == visitor_address

        email.body.raw_source.should include("email: pvb.rochester@maildrop.dsd.io")
        email.body.raw_source.should include("phone: 01634 803100")
        email.body.raw_source.should_not include("Jimmy Harris")
        email.body.raw_source.should include('5551234')
        email.body.raw_source.should include('The following visitors cannot attend because they are not listed')
      end

      it "sends out an e-mail with the list of banned visitors" do
        email = subject.booking_confirmation_email(sample_visit, confirmation_banned_visitors)
        email.subject.should == "Visit confirmed: your visit for 7 July 2013 has been confirmed"

        email[:from].should == noreply_address
        email[:reply_to].should == prison_address
        email[:to].should == visitor_address

        email.body.raw_source.should include("email: pvb.rochester@maildrop.dsd.io")
        email.body.raw_source.should include("phone: 01634 803100")
        email.body.raw_source.should_not include("Jimmy Harris")
        email.body.raw_source.should include('5551234')
        email.body.raw_source.should include('The following visitors cannot attend because they are banned')
      end

      it "sends out an e-mail with the List-Unsubscribe header set" do
        header_value = '<https://www.prisonvisits.service.gov.uk/unsubscribe>'
        subject.booking_receipt_email(sample_visit)['List-Unsubscribe'].value.should ==  header_value
        [confirmation_no_slot_available, confirmation_not_on_contact_list, confirmation_no_vos_left].each do |outcome|
          subject.booking_rejection_email(sample_visit, outcome)['List-Unsubscribe'].value.should == header_value
        end
        subject.booking_confirmation_email(sample_visit, confirmation)['List-Unsubscribe'].value.should == header_value
      end
    end

    context "sends out an unsuccessful e-mail with a date in the subject" do
      it "because of a slot not being available" do
        email = subject.booking_rejection_email(sample_visit, confirmation_no_slot_available)
        email.subject.should == "Visit cannot take place: your visit for 7 July 2013 could not be booked"

        email[:from].should == noreply_address
        email[:reply_to].should == prison_address
        email[:to].should == visitor_address

        email.body.raw_source.should include('http://www.justice.gov.uk/contacts/prison-finder/rochester')
        email.body.raw_source.should include("01634 803100")
        email.body.raw_source.should_not include("Jimmy Harris")
      end

      it "because of a visitor not being on a contact list" do
        email = subject.booking_rejection_email(sample_visit, confirmation_not_on_contact_list)
        email.subject.should == "Visit cannot take place: your visit for 7 July 2013 could not be booked"

        email[:from].should == noreply_address
        email[:reply_to].should == prison_address
        email[:to].should == visitor_address

        email.body.raw_source.should include('http://www.justice.gov.uk/contacts/prison-finder/rochester')
        email.body.raw_source.should include("01634 803100")
        email.body.raw_source.should_not include("Jimmy Harris")
      end

      it "because the prisoner details are incorrect" do
        email = subject.booking_rejection_email(sample_visit, rejection_prisoner_incorrect)
        email.subject.should == "Visit cannot take place: your visit for 7 July 2013 could not be booked"

        email[:from].should == noreply_address
        email[:reply_to].should == prison_address
        email[:to].should == visitor_address

        email.body.raw_source.should include('http://www.justice.gov.uk/contacts/prison-finder/rochester')
        email.body.raw_source.should include("01634 803100")
        email.body.raw_source.should_not include("Jimmy Harris")
        email.body.raw_source.should include("You haven’t given correct information for the prisoner.")
      end

      it "because the prisoner is not at the prison" do
        email = subject.booking_rejection_email(sample_visit, rejection_prisoner_not_present)
        email.subject.should == "Visit cannot take place: your visit for 7 July 2013 could not be booked"

        email[:from].should == noreply_address
        email[:reply_to].should == prison_address
        email[:to].should == visitor_address

        email.body.raw_source.should include('http://www.justice.gov.uk/contacts/prison-finder/rochester')
        email.body.raw_source.should include("01634 803100")
        email.body.raw_source.should_not include("Jimmy Harris")
        email.body.raw_source.should include("The prisoner you want to visit has moved prison.")
      end

      it "because a visitor is not on the list" do
        email = subject.booking_rejection_email(sample_visit, rejection_visitor_not_listed)
        email.subject.should == "Visit cannot take place: your visit for 7 July 2013 could not be booked"

        email[:from].should == noreply_address
        email[:reply_to].should == prison_address
        email[:to].should == visitor_address

        email.body.raw_source.should include('http://www.justice.gov.uk/contacts/prison-finder/rochester')
        email.body.raw_source.should include("01634 803100")
        email.body.raw_source.should_not include("Jimmy Harris")
        email.body.raw_source.should include("The details you’ve provided for Joan Harris don’t match what we have on our records.")
      end

      it "because a visitor is not on the list" do
        email = subject.booking_rejection_email(sample_visit, rejection_visitor_banned)
        email.subject.should == "Visit cannot take place: your visit for 7 July 2013 could not be booked"

        email[:from].should == noreply_address
        email[:reply_to].should == prison_address
        email[:to].should == visitor_address

        email.body.raw_source.should include('http://www.justice.gov.uk/contacts/prison-finder/rochester')
        email.body.raw_source.should include("01634 803100")
        email.body.raw_source.should_not include("Jimmy Harris")
        email.body.raw_source.should include("Joan Harris should have received a letter to say that they’re banned from visiting the prison at the moment.")
      end
    end

    context "booking receipt sent" do
      it "sends out an e-mail with a date in the subject" do
        email = subject.booking_receipt_email(sample_visit)
        email.subject.should == "Not booked yet: we've received your visit request for 7 July 2013"
        email[:from].should == noreply_address
        email[:reply_to].should == prison_address
        email[:to].should == visitor_address
        email.body.raw_source.should_not include("Jimmy Harris")
        email.body.raw_source.should include(visit_status_url(id: sample_visit.visit_id))
        email.body.raw_source.should match(/by Friday  5 July to/)
      end
    end

    it "sends an e-mail to the person who requested a booking" do
      subject.booking_confirmation_email(sample_visit, confirmation)[:to].should == visitor_address
    end
  end
end
