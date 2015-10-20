require 'rails_helper'
require_relative './concerns/visitor_mailer_shared_conditions.rb'

RSpec.describe VisitorMailer do
  subject! { described_class }

  include_context 'shared conditions for visitor mailer'
  it_behaves_like 'a mailer that ensures content transfer encoding is quoted printable'

  it "relays e-mails via sendgrid" do
    expect(VisitorMailer.smtp_settings).to eq(ActionMailer::Base.smtp_settings)
  end

  it "delivers an automated response" do
    expect {
      VisitorMailer.autorespond(email).tap do |m|
        expect(m[:from]).to eq(noreply_address)
        expect(m[:to]).to eq(visitor_address)
      end.deliver_now
    }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  shared_examples 'an email without spam and bounce reset checks' do
    it 'makes no attempt at resets' do
      expect_any_instance_of(SpamAndBounceResets).to_not receive(:perform_resets)
      email.deliver_now
    end
  end

  context "when booking is successful" do
    it_behaves_like 'an email without spam and bounce reset checks' do
      let(:email) { subject.booking_confirmation_email(sample_visit, confirmation, token) }
    end

    it "sends out an e-mail with a reference number" do
      email = subject.booking_confirmation_email(sample_visit, confirmation_canned_response, token)
      expect(email.subject).to eq("Visit confirmed: your visit for Sunday 7 July 2013 has been confirmed")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html(prison_email)
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html('5551234')
      expect(email).not_to match_in_html("This is a copy")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "sends out an e-mail with no reference number for remand prisoners" do
      email = subject.booking_confirmation_email(sample_visit, confirmation_canned_response_remand, token)
      expect(email.subject).to eq("Visit confirmed: your visit for Sunday 7 July 2013 has been confirmed")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html(prison_email)
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).not_to match_in_html('Your reference number is')

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "sends out an e-mail with the list of visitors not on the approved visitor list" do
      email = subject.booking_confirmation_email(sample_visit, confirmation_unlisted_visitors, token)
      expect(email.subject).to eq("Visit confirmed: your visit for Sunday 7 July 2013 has been confirmed")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html(prison_email)
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("Joan H. cannot attend as they’re not on the prisoner’s contact list")
      expect(email).to match_in_html('5551234')

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "sends out an e-mail with the list of banned visitors" do
      email = subject.booking_confirmation_email(sample_visit, confirmation_banned_visitors, token)
      expect(email.subject).to eq("Visit confirmed: your visit for Sunday 7 July 2013 has been confirmed")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html(prison_email)
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("Joan H. cannot attend as they’re currently banned")
      expect(email).to match_in_html('5551234')

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "sends out an e-mail notifying visitors that it is a closed visit" do
      email = subject.booking_confirmation_email(sample_visit, confirmation_closed_visit, token)
      expect(email.subject).to eq("Visit confirmed: your visit for Sunday 7 July 2013 has been confirmed")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html('5551234')
      expect(email).to match_in_html('This is a closed visit')
    end

    it "sends out an e-mail with the List-Unsubscribe header set" do
      header_value = '<https://www.prisonvisits.service.gov.uk/unsubscribe>'
      expect(subject.booking_receipt_email(sample_visit, "token")['List-Unsubscribe'].value).to eq(header_value)
      [confirmation_no_slot_available, confirmation_not_on_contact_list, confirmation_no_vos_left].each do |outcome|
        expect(subject.booking_rejection_email(sample_visit, outcome)['List-Unsubscribe'].value).to eq(header_value)
      end
      expect(subject.booking_confirmation_email(sample_visit, confirmation, token)['List-Unsubscribe'].value).to eq(header_value)
    end
  end

  context "sends out an unsuccessful e-mail with a date in the subject" do
    it_behaves_like 'an email without spam and bounce reset checks' do
      let(:email) { subject.booking_rejection_email(sample_visit, confirmation_no_slot_available) }
    end

    it "because of a slot not being available" do
      email = subject.booking_rejection_email(sample_visit, confirmation_no_slot_available)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July 2013 could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because of a visitor not being on a contact list (legacy)" do
      email = subject.booking_rejection_email(sample_visit, confirmation_not_on_contact_list)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July 2013 could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because the prisoner details are incorrect" do
      email = subject.booking_rejection_email(sample_visit, rejection_prisoner_incorrect)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July 2013 could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("Your visit cannot take place as you haven’t given correct information for the prisoner.")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because the prisoner is not at the prison" do
      email = subject.booking_rejection_email(sample_visit, rejection_prisoner_not_present)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July 2013 could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("Your visit cannot take place as the prisoner you want to visit has moved prison.")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because the prisoner has no allowance" do
      email = subject.booking_rejection_email(sample_visit, rejection_prisoner_no_allowance)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July 2013 could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("the prisoner you want to visit has not got any visiting allowance left for the dates you’ve chosen")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because the prisoner has no allowance and a VO renewal date is specified" do
      email = subject.booking_rejection_email(sample_visit, rejection_prisoner_no_allowance_vo_renew)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July 2013 could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("the prisoner you want to visit has not got any visiting allowance left for the dates you’ve chosen")
      expect(email).to match_in_html("Jimmy H will have their full visiting allowance (VO) renewed on Saturday 29 November.")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because the prisoner has no allowance and a PVO renewal date is specified" do
      email = subject.booking_rejection_email(sample_visit, rejection_prisoner_no_allowance_pvo_renew)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July 2013 could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("the prisoner you want to visit has not got any visiting allowance left for the dates you’ve chosen")
      expect(email).to match_in_html("However, you can book a weekday visit with visiting allowance valid until Monday 17 November.")
      expect(email).to match_in_html("Jimmy H will have their full visiting allowance (VO) renewed on Saturday 29 November.")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because a visitor is not on the list (canned response)" do
      email = subject.booking_rejection_email(sample_visit, rejection_visitor_not_listed)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July 2013 could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("Your visit cannot take place as details for Joan Harris don’t match our records or they aren’t on the prisoner’s contact list.")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "because a visitor is banned" do
      email = subject.booking_rejection_email(sample_visit, rejection_visitor_banned)
      expect(email.subject).to eq("Visit cannot take place: your visit for Sunday 7 July 2013 could not be booked")

      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)

      expect(email).to match_in_html('http://www.justice.gov.uk/contacts/prison-finder/rochester')
      expect(email).to match_in_html("01634 803100")
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html("Joan Harris should have received a letter to say that they’re banned from visiting the prison at the moment.")

      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end
  end

  context "booking receipt is sent" do
    before do
      # TODO: I dislike this as a solution, but seem unable to persist any changes to
      # Prison#lead_days when it is being accessed via the Visit model (at the time of
      # writing, Prison is a Virtus model.
      allow_any_instance_of(PrisonSchedule).to receive(:days_lead_time).
        and_return(double('days', zero?: true))
    end

    it "attempts spam and bounce resets" do
      expect_any_instance_of(SpamAndBounceResets).to receive(:perform_resets)
      subject.booking_receipt_email(sample_visit, token).deliver_now
    end

    it "with a date in the subject" do
      email = subject.booking_receipt_email(sample_visit, "token")
      expect(email.subject).to eq("Not booked yet: we've received your visit request for Sunday 7 July 2013")
      expect(email[:from]).to eq(noreply_address)
      expect(email[:reply_to]).to eq(prison_address)
      expect(email[:to]).to eq(visitor_address)
      expect(email).not_to match_in_html("Jimmy Harris")
      expect(email).to match_in_html(visit_status_url(id: sample_visit.visit_id))
      # On Rochester, using production data, this fails if lead_days is set to the default of 3.
      # This is because it breaks over a weekend and the next working day that qualifies is the 9th.
      # The issue is expalined here: https://www.pivotaltracker.com/story/show/105232814
      expect(email).to match_in_html("by Friday 5 July to")
      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text(sample_visit.visit_id)
    end
  end

  it "sends an e-mail to the person who requested a booking" do
    expect(subject.booking_confirmation_email(sample_visit, confirmation, token)[:to]).to eq(visitor_address)
  end
end
