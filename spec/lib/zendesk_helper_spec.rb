require 'spec_helper'
require 'zendesk_helper'

describe ZendeskHelper do
  let :subject do
    ZendeskHelper
  end

  let :feedback do
    Feedback.new(text: 'text', email: 'email', referrer: 'ref', user_agent: 'Mozilla')
  end

  let :client do
    ZendeskAPI::Client.new do |c|
      c.url = 'https://lol.biz.info/api/v2'
    end
  end

  it "sends a piece of feedback to zendesk" do
    ZendeskAPI::Ticket.should_receive(:new).with(client, description: 'text', requester: { email: 'email', name: 'Unknown' }, custom_fields: [
                                                                                                                             {id: '23730083', value: 'ref'},
                                                                                                                             {id: '23757677', value: 'prison_visits'},
                                                                                                                             {id: '23791776', value: 'Mozilla'}
                                                                                                                            ]).and_call_original
    ZendeskAPI::Ticket.any_instance.should_receive(:save!).once
    subject.send_to_zendesk(feedback, client)
  end
end
