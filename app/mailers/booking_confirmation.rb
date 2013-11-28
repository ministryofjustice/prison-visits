class BookingConfirmation < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  def confirmation_email(visit)
    @visit = visit
    email = visit.visitors.find { |v| v.email }.email

    recipient = if production?
      email
    else
      'pvb-email-test@googlegroups.com'
    end

    mail(from: 'prisonvisitsbooking@digital.justice.gov.uk', to: recipient, subject: 'Visit confirmation')
  end

  def production?
    ENV['APP_PLATFORM'] == 'production'
  end
end
