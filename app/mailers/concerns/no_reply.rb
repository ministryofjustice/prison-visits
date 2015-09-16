module NoReply
  include ActiveSupport::Concern

  def noreply_address
    "Prison Visits Booking (Unattended) <no-reply@#{smtp_domain}>"
  end

  def smtp_domain
    ENV['SMTP_DOMAIN']
  end
end
