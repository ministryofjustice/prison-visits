RSpec.shared_context "shared conditions for visitor mailer" do
  before do
    ActionMailer::Base.deliveries.clear
    allow_any_instance_of(VisitorMailer).to receive(:smtp_domain).and_return('example.com')
    Prison.find('Rochester').lead_days = 0
  end

  around do |example|
    Timecop.freeze(Time.zone.local(2013, 7, 4)) do
      example.run
    end
  end

  let(:email) {
    ParsedEmail.parse(
      from: "visitor@example.com",
      to: 'test@example.com',
      text: "some text",
      charsets: { to: "UTF-8", html: "utf-8", subject: "UTF-8", from: "UTF-8", text: "utf-8" }.to_json,
      subject: "important email"
    )
  }

  let :confirmation do
    Confirmation.new(message: 'A message', outcome: 'slot_0')
  end

  let :confirmation_canned_response do
    Confirmation.new(canned_response: true, outcome: 'slot_0', vo_number: '5551234')
  end

  let :confirmation_canned_response_remand do
    Confirmation.new(canned_response: true, outcome: 'slot_0', vo_number: 'none')
  end

  let :confirmation_unlisted_visitors do
    Confirmation.new(canned_response: true, vo_number: '5551234', outcome: 'slot_0', visitor_not_listed: true, unlisted_visitors: ['Joan;Harris'])
  end

  let :confirmation_banned_visitors do
    Confirmation.new(canned_response: true, vo_number: '5551234', outcome: 'slot_0', visitor_banned: true, banned_visitors: ['Joan;Harris'])
  end

  let :confirmation_closed_visit do
    Confirmation.new(canned_response: true, vo_number: '5551234', outcome: 'slot_0', closed_visit: true)
  end

  let :confirmation_no_slot_available do
    Confirmation.new(message: 'A message', outcome: Confirmation::NO_SLOT_AVAILABLE)
  end

  let :confirmation_not_on_contact_list do
    Confirmation.new(message: 'A message', outcome: Confirmation::NOT_ON_CONTACT_LIST)
  end

  let :rejection_prisoner_incorrect do
    Confirmation.new(outcome: Confirmation::PRISONER_INCORRECT)
  end

  let :rejection_prisoner_not_present do
    Confirmation.new(outcome: Confirmation::PRISONER_NOT_PRESENT)
  end

  let :rejection_prisoner_no_allowance do
    Confirmation.new(outcome: Confirmation::NO_ALLOWANCE)
  end

  let :rejection_prisoner_no_allowance_vo_renew do
    Confirmation.new(outcome: Confirmation::NO_ALLOWANCE, no_vo: true, renew_vo: '2014-11-29')
  end

  let :rejection_prisoner_no_allowance_pvo_renew do
    Confirmation.new(outcome: Confirmation::NO_ALLOWANCE, no_vo: true, renew_vo: '2014-11-29', no_pvo: true, renew_pvo: '2014-11-17')
  end

  let :rejection_visitor_not_listed do
    Confirmation.new(visitor_not_listed: true, unlisted_visitors: ['Joan;Harris'])
  end

  let :rejection_visitor_banned do
    Confirmation.new(visitor_banned: true, banned_visitors: ['Joan;Harris'])
  end

  let(:confirmation_no_vos_left) { Confirmation.new(message: 'A message', outcome: Confirmation::NO_VOS_LEFT) }
  let(:noreply_address) { Mail::Field.new('from', "Prison Visits Booking <no-reply@example.com> (Unattended)") }
  let(:visitor_address) { Mail::Field.new('to', "Mark Harris <visitor@example.com>") }
  let(:prison_email) { 'pvb.RCI@maildrop.dsd.io' }
  let(:prison_address) { Mail::Field.new('reply-to', prison_email) }
  let(:token) { MESSAGE_ENCRYPTOR.encrypt_and_sign(sample_visit) }
end
