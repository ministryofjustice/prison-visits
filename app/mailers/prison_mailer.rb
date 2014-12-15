class PrisonMailer < ActionMailer::Base

  include MailerHelper::NoReply
  include MailerHelper::Autoresponder
  include MailerHelper::Addresses

  add_template_helper(ApplicationHelper)
  add_template_helper(VisitHelper)

  layout 'email'

  attr_reader :visit
  helper_method :visit

  def self.smtp_settings
    {
      address: ENV['GSI_SMTP_HOSTNAME'],
      port: ENV['GSI_SMTP_PORT'],
      domain: ENV['GSI_SMTP_DOMAIN'],
      enable_starttls_auto: true
    }
  end

  def booking_request_email(visit, token)
    @visit = visit
    user = visit.visitors.find { |v| v.email }.email
    @token = token

    mail(from: sender, reply_to: user, to: recipient, subject: "Visit request for #{@visit.prisoner.full_name} on #{Date.parse(@visit.slots.first.date).strftime('%A %e %B')}")
  end

  def booking_receipt_email(visit, confirmation)
    @visit = visit
    @confirmation = confirmation

    if confirmation.slot_selected?
      @slot = visit.slots[confirmation.slot]
      mail(from: sender, to: recipient, subject: "COPY of booking confirmation for #{@visit.prisoner.full_name}",
           template_name: "booking_confirmation_email")
    else
      mail(from: sender, to: recipient, subject: "COPY of booking rejection for #{@visit.prisoner.full_name}",
           template_name: "booking_rejection_email")
    end
  end

  def booking_cancellation_receipt_email(visit)
    @visit = visit

    mail(from: sender, reply_to: user, to: recipient, subject: "Visit for #{@visit.prisoner.full_name} has been cancelled")
  end

  def sender
    noreply_address
  end

  def recipient
    prison_mailbox_email
  end
end
