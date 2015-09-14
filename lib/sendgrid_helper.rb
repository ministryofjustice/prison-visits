module SendgridHelper
  def self.spam_reported?(email)
    return false unless can_access_sendgrid?
    spam_reports = SendgridToolkit::SpamReports.new(user_name, password)
    spam_reports.retrieve(email: email).any?
  rescue SendgridToolkit::APIError
    false
  end

  def self.bounced?(email)
    return false unless can_access_sendgrid?
    bounces = SendgridToolkit::Bounces.new(user_name, password)
    bounces.retrieve(email: email).any?
  rescue SendgridToolkit::APIError
    false
  end

  def self.smtp_alive?(host, port)
    Net::SMTP.start(host, port) do |smtp|
      smtp.enable_starttls_auto
      smtp.ehlo(Socket.gethostname)
      smtp.finish
    end
    true
  rescue StandardError => e
    false
  end

  private

  def self.can_access_sendgrid?
    user_name && password
  end

  def self.user_name
    smtp_settings[:user_name]
  end

  def self.password
    smtp_settings[:password]
  end

  def self.smtp_settings
    Rails.configuration.action_mailer.smtp_settings || {}
  end
end
