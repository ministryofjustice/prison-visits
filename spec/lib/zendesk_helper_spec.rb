require 'rails_helper'
require 'zendesk_helper'

RSpec.describe ZendeskHelper do
  let :subject do
    ZendeskHelper
  end

  let :feedback do
    Feedback.new(text: 'text', email: 'email', referrer: 'ref', user_agent: 'Mozilla')
  end

  let :feedback_with_prison do
    feedback.tap do |f|
      f.prison = 'Rochester'
    end
  end

  let :client do
    ZendeskAPI::Client.new do |c|
      c.url = 'https://lol.biz.info/api/v2'
    end
  end

  it "sends a piece of feedback to zendesk" do
    expect(ZendeskAPI::Ticket).to receive(:new).with(client, description: 'text', requester: { email: 'email', name: 'Unknown' }, custom_fields: [
                                                                                                                             {id: '23730083', value: 'ref'},
                                                                                                                             {id: '23757677', value: 'prison_visits'},
                                                                                                                             {id: '23791776', value: 'Mozilla'},
                                                                                                                             {id: '23984153', value: nil}
                                                                                                                            ]).and_call_original
    expect_any_instance_of(ZendeskAPI::Ticket).to receive(:save!).once
    subject.send_to_zendesk(feedback, client)
  end

  context "when a prison name is passed in" do
    it "sends a piece of feedback to zendesk with the prison name" do
      expect(ZendeskAPI::Ticket).to receive(:new).with(client, description: 'text', requester: { email: 'email', name: 'Unknown' }, custom_fields: [
                                                                                                                                                {id: '23730083', value: 'ref'},
                                                                                                                                                {id: '23757677', value: 'prison_visits'},
                                                                                                                                                {id: '23791776', value: 'Mozilla'},
                                                                                                                                                {id: '23984153', value: 'Rochester'}
                                                                                                                                               ]).and_call_original
      expect_any_instance_of(ZendeskAPI::Ticket).to receive(:save!).once
      subject.send_to_zendesk(feedback_with_prison, client)
    end
  end
end
