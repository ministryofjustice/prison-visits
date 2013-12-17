module ZendeskHelper
  def self.send_to_zendesk(feedback, client=ZENDESK_CLIENT)
    ZendeskAPI::Ticket.new(client, description: feedback.text, requester: { email: feedback.email }, custom_fields: [{id: '23730083', value: feedback.referrer}, {id: '23757677', value: 'prison_visits'}]).save
  end
end

