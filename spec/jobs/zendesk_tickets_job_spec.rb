require 'rails_helper'

RSpec.describe ZendeskTicketsJob, type: :job do
  subject { described_class }

  let(:feedback) {
    Feedback.new(
      text: 'text',
      email: 'email@example.com',
      referrer: 'ref',
      user_agent: 'Mozilla'
    )
  }

  let(:client) {
    ZENDESK_CLIENT
  }

  let(:ticket) {
    double(ZendeskAPI::Ticket, save!: nil)
  }

  it 'creates a ticket with feedback and custom fields' do
    expect(ZendeskAPI::Ticket).
      to receive(:new).
      with(
        client,
        description: 'text',
        requester: { email: 'email@example.com', name: 'Unknown' },
        custom_fields: [
          {id: '23730083', value: 'ref'},
          {id: '23757677', value: 'prison_visits'},
          {id: '23791776', value: 'Mozilla'},
          {id: '23984153', value: nil}
        ]
      ).and_return(ticket)
    subject.perform_now(feedback)
  end

  it 'calls save! to send the feedback' do
    allow(ZendeskAPI::Ticket).
      to receive(:new).
      and_return(ticket)
    expect(ticket).to receive(:save!).once
    subject.perform_now(feedback)
  end

  context 'when the prison name is available' do
    let(:feedback) {
      super().tap { |f| f.prison = 'Rochester' }
    }

    it 'includes it as custom data' do
      expect(ZendeskAPI::Ticket).
        to receive(:new).
        with(
          anything,
          include(
            custom_fields: include(id: '23984153', value: 'Rochester')
          )
        ).and_return(ticket)
      subject.perform_now(feedback)
    end
  end
end
