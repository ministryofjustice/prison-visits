module MailerHelper
  module NoReply
    def noreply_address
      "Prison Visits Booking (Unattended) <no-reply@#{smtp_domain}>"
    end
    
    def smtp_domain
      ENV['SMTP_DOMAIN']
    end
  end

  module Autoresponder
    def autorespond(parsed_email)
      mail(from: noreply_address, to: parsed_email.from.to_s, subject: 'This mailbox is not monitored')
    end
  end
end
