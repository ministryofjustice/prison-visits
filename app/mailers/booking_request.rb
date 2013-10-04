class BookingRequest < ActionMailer::Base
  def request_email(visit)
    @visit = visit
    user = visit.visitors.find { |v| v.email }.email
    mail(from: 'prisonvisitsbooking@digital.justice.gov.uk', to: 'pvb-email-test@googlegroups.com', subject: 'Visit request', reply_to: user)
  end
end
