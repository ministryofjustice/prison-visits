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

  module Addresses
    def prison_mailbox_email
      Rails.configuration.prison_data[@visit.prisoner.prison_name]['email']
    end
    
    def first_visitor_email
      visitor = @visit.visitors.find { |v| v.email }
      Mail::Address.new.tap do |m|
        m.display_name = visitor.full_name
        m.address = visitor.email
      end.to_s
    end
  end
end
