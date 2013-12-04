module ZendeskHelper
  def self.send_to_zendesk(feedback, client=ZENDESK_CLIENT)
    ZendeskAPI::Ticket.new(client, description: feedback.text, submitter: { email: feedback.email }, custom_fields: [{id: '23730083', value: feedback.referrer}]).save
  end
end

