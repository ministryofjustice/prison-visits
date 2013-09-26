class BookingRequest < ActionMailer::Base
  def request_email(visit)
    @visit = visit
    from = visit.visitors.find { |v| v.email }.email
    mail(from: from, to: 'pvb-email-test@googlegroups.com', subject: 'Visit request')
  end
end
