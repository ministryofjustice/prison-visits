require 'spec_helper'
require 'zendesk_helper'

describe ZendeskHelper do
  let :subject do
    ZendeskHelper
  end

  let :feedback do
    Feedback.new(text: 'text', email: 'email', referrer: 'ref')
  end

  let :client do
    ZendeskAPI::Client.new do |c|
      c.url = 'https://lol.biz.info'
    end
  end

  it "sends a piece of feedback to zendesk" do
    mock_ticket = mock('ticket')
    mock_ticket.should_receive('save').once
    ZendeskAPI::Ticket.should_receive(:new).with(client, description: 'text', submitter: { email: 'email' }, custom_fields: [{id: '23730083', value: 'ref'}]).and_return(mock_ticket)

    subject.send_to_zendesk(feedback, client)
  end
end