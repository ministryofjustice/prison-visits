require 'mailer_helper'

class PrisonMailer < ActionMailer::Base
  self.smtp_settings = {
    address: ENV['GSI_SMTP_HOSTNAME'],
    port: ENV['GSI_SMTP_PORT'],
    domain: ENV['GSI_SMTP_DOMAIN'],
    enable_starttls_auto: true
  }

  include MailerHelper::NoReply
  include MailerHelper::Autoresponder
end
