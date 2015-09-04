module ZendeskHelper
  def self.send_to_zendesk(feedback, client = ZENDESK_CLIENT)
    ZendeskAPI::Ticket.create!(
      client,
      description: feedback.text,
      requester: {
        email: feedback.email,
        name: 'Unknown'
      },
      custom_fields: [
        { id: '23730083', value: feedback.referrer },
        { id: '23757677', value: 'prison_visits' },
        { id: '23791776', value: feedback.user_agent },
        { id: '23984153', value: feedback.prison }
      ]
    )
  end
end

