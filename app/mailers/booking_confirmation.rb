class BookingConfirmation < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  def confirmation_email(visit)
    @visit = visit
    email = visit.visitors.find { |v| v.email }.email

    prison_mailbox = Rails.configuration.prison_data[visit.prisoner.prison_name]['email']

    first_date = Date.parse(@visit.slots.first.date)
    mail(sender: sender, from: prison_mailbox, reply_to: prison_mailbox, to: email, subject: "You have requested a visit for #{first_date.strftime('%e %B %Y').gsub(/^ /,'')}")
  end

  def production?
    ENV['APP_PLATFORM'] == 'production'
  end

  def sender
    production? ? ENV['SMTP_SENDER'] : 'test@example.com'
  end
end
