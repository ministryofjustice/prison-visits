class FeedbackMailer < ActionMailer::Base
  default from: 'no-reply@digital.justice.gov.uk', to: 'prisonvisits@digital.justice.gov.uk'

  def new_feedback(feedback)
    @feedback = feedback
    mail(subject: "PVB feedback: #{feedback.referrer}")
  end
end
