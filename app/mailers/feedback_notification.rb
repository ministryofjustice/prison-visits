class FeedbackNotification < ActionMailer::Base
  default from: 'no-reply@digital.justice.gov.uk', to: 'prisonvisits@digital.justice.gov.uk'

  def new_message(message)
    @message = message
    mail(subject: "PVB feedback: #{message.referrer}")
  end
end
