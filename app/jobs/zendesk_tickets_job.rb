class ZendeskTicketsJob < ActiveJob::Base
  queue_as :zendesk

  def perform(feedback)
    ZendeskAPI::Ticket.create!(
      ZENDESK_CLIENT,
      description: feedback.text,
      requester: {
        email: feedback.email,
        name: 'Unknown'
      },
      custom_fields: custom_fields(feedback)
    )
  end

  def custom_fields(feedback)
    [
      { id: '23730083', value: feedback.referrer },
      { id: '23757677', value: 'prison_visits' },
      { id: '23791776', value: feedback.user_agent },
      { id: '23984153', value: feedback.prison }
    ]
  end
end
