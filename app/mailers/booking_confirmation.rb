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

    first_date = Date.parse(@visit.slots.first.date)
    mail(from: sender, to: recipient, subject: "Your visit request for#{first_date.strftime('%e %B %Y')}")
  end

  def production?
    ENV['APP_PLATFORM'] == 'production'
  end

  def sender
    ENV['SMTP_SENDER']
  end
end
