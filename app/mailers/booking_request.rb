class BookingRequest < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  self.smtp_settings = {
    address: ENV['GSI_SMTP_HOSTNAME'],
    port: ENV['GSI_SMTP_PORT'],
    domain: ENV['GSI_SMTP_DOMAIN'],
    enable_starttls_auto: true
  }

  def request_email(visit)
    @visit = visit
    user = visit.visitors.find { |v| v.email }.email

    recipient = Rails.configuration.prison_data[visit.prisoner.prison_name.to_s]['email']

    mail(sender: sender, from: user, reply_to: user, to: recipient, subject: "Visit request for #{@visit.prisoner.full_name}")
  end

  def sender
    ENV['SMTP_SENDER']
  end
end
