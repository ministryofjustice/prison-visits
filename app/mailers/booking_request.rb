class BookingRequest < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  EMAILS = {
    'Rochester' => 'socialvisits.rochester@hmps.gsi.gov.uk',
    # 'Durham' => 'socialvisits.durham@hmps.gsi.gov.uk'
  }

  self.smtp_settings = {
    address: ENV['GSI_SMTP_HOSTNAME'],
    port: ENV['GSI_SMTP_PORT'],
    domain: ENV['GSI_SMTP_DOMAIN'],
    enable_starttls_auto: true
  }

  def request_email(visit)
    @visit = visit
    user = visit.visitors.find { |v| v.email }.email

    recipient = if production?
      EMAILS[visit.prisoner.prison_name]
    else
      'pvb-email-test@googlegroups.com'
    end

    mail(from: sender, to: recipient, subject: "Visit request for #{@visit.prisoner.full_name}", reply_to: user)
  end

  def production?
    ENV['APP_PLATFORM'] == 'production'
  end

  def sender
    ENV['SMTP_SENDER']
  end
end
