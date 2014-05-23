class FeedbackNotification < ActionMailer::Base
  default from: "no-reply@#{ENV['SMTP_DOMAIN']}", to: 'prisonvisits@digital.justice.gov.uk'

  def new_message(message)
    @message = message
    mail(subject: "PVB feedback: #{message.referrer}")
  end
end
