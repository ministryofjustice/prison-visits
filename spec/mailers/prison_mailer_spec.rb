require 'rails_helper'

RSpec.describe PrisonMailer do
  before :each do
    ActionMailer::Base.deliveries.clear
    allow_any_instance_of(PrisonMailer).to receive(:smtp_domain).and_return('example.com')
  end

  let :email do
    ParsedEmail.parse({
        from: "nonexistent@hmps.gsi.gov.uk",
        to: 'test@example.com',
        text: "some text",
        charsets: {to: "UTF-8", html: "utf-8", subject: "UTF-8", from: "UTF-8", text: "utf-8"}.to_json,
        subject: "important email"
    })
  end

  it_behaves_like 'a mailer that ensures content transfer encoding is quoted printable'

  it "relays e-mails via GSI" do
    expect(PrisonMailer.smtp_settings).not_to eq(ActionMailer::Base.smtp_settings)
  end

  it "delivers an automated response" do
    expect {
      PrisonMailer.autorespond(email).tap do |m|
        expect(m.from).to eq(['no-reply@example.com'])
        expect(m.to).to eq(['nonexistent@hmps.gsi.gov.uk'])
      end.deliver_now
    }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  let! :subject do
    PrisonMailer
  end

  let :confirmation_with_slot do
    Confirmation.new(message: 'A message', outcome: 'slot_0', vo_number: '1234567')
  end

  let :confirmation_without_slot do
    Confirmation.new(message: 'A message', outcome: Confirmation::NO_SLOT_AVAILABLE)
  end

  let :confirmation_not_on_contact_list do
    Confirmation.new(message: 'A message', outcome: Confirmation::NOT_ON_CONTACT_LIST)
  end

  let :confirmation_no_vos_left do
    Confirmation.new(message: 'A message', outcome: Confirmation::NO_VOS_LEFT)
  end

  context 'first visitor has smoke test details' do
    let(:smoke_test_email) { 'smoke-tests@example.com' }

    let(:smoke_test_visit) do
      sample_visit.tap do |visit|
        visit.visitors.first.email = smoke_test_email
      end
    end

    before do
      allow_any_instance_of(MailUtilities::SmokeTestEmailCheck).
        to receive(:matches?).and_return true
    end

    it 'alters the mail settings to not send to the prison' do
      subject.booking_request_email(smoke_test_visit, "token").tap do |email|
        expect(email.to).to contain_exactly smoke_test_email
      end
    end
  end

  context "always" do
    it "sends an e-mail with the prisoner name in the subject" do
      expect(subject.booking_request_email(sample_visit, "token").subject).to eq('Visit request for Jimmy Harris on Sunday 7 July 2013')
    end

    it "sends an e-mail with a long link to the confirmation page" do
      email = subject.booking_request_email(sample_visit, "token")
      expect(email).to match_in_html "confirmation/new?state=token"
      expect(email).to match_in_html "https://localhost"
      expect(email).to match_in_html(sample_visit.visit_id)
      expect(email).to match_in_text "confirmation/new?state=token"
      expect(email).to match_in_text "https://localhost"
      expect(email).to match_in_text(sample_visit.visit_id)
    end

    it "sends a booking receipt to a prison to create an audit trail" do
      subject.booking_receipt_email(sample_visit, confirmation_with_slot).tap do |email|
        expect(email.subject).to eq("COPY of booking confirmation for Jimmy Harris")
        expect(email).to match_in_html('Mark')
        expect(email).to match_in_html('This is a copy of the booking confirmation email sent to the visitor')
        expect(email).to match_in_html(sample_visit.visit_id)
        expect(email).to match_in_text('Mark')
        expect(email).to match_in_text('THIS IS A COPY OF THE BOOKING CONFIRMATION EMAIL THAT HAS BEEN SENT TO THE VISITOR')
        expect(email).to match_in_text(sample_visit.visit_id)
      end

      [confirmation_without_slot, confirmation_not_on_contact_list, confirmation_no_vos_left].each do |confirmation|
        subject.booking_receipt_email(sample_visit, confirmation).tap do |email|
          expect(email.subject).to eq("COPY of booking rejection for Jimmy Harris")
          expect(email).to match_in_html('Mark')
          expect(email).to match_in_html(sample_visit.visit_id)
          expect(email).to match_in_text('Mark')
          expect(email).to match_in_text(sample_visit.visit_id)
        end
      end
    end

    it "sends an e-mail to rochester functional mailbox" do
      sample_visit.tap do |visit|
        visit.prison_name = 'Rochester'
        expect(subject.booking_request_email(visit, "token").to).to eq(['pvb.RCI@maildrop.dsd.io'])
      end
    end

    it "sends an cancellation notification to a prison so it can be removed from NOMIS" do
      subject.booking_cancellation_receipt_email(sample_visit).tap do |email|
        expect(email['X-Priority'].value).to eq('1 (Highest)')
        expect(email['X-MSMail-Priority'].value).to eq('High')
        expect(email.subject).to eq('CANCELLED: Jimmy Harris on Sunday 7 July 2013')
        expect(email).to match_in_text('a0000aa')
        expect(email).to match_in_text(sample_visit.visit_id)
        expect(email).to match_in_text('87654321')
      end
    end

    it "sends an e-mail with a link over https" do
      expect(subject.booking_request_email(sample_visit, "token")).to match_in_html "https://localhost"
    end

    it "uses its own configuration (GSI)" do
      expect(subject.smtp_settings).not_to be === ActionMailer::Base.smtp_settings
    end
  end
end
