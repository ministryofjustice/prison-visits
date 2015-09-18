class SendgridApi
  extend SingleForwardable

  def_single_delegators :new, :spam_reported?, :bounced?,
    :smtp_alive?, :remove_from_bounce_list, :remove_from_spam_list

  def spam_reported?(email)
    return false unless can_access_sendgrid?
    spam_reports.retrieve(email: email).any?
  rescue JSON::ParserError, SendgridToolkit::APIError
    false
  end

  def bounced?(email)
    return false unless can_access_sendgrid?
    bounces.retrieve(email: email).any?
  rescue JSON::ParserError, SendgridToolkit::APIError
    false
  end

  def remove_from_bounce_list(email)
    return false unless can_access_sendgrid?
    bounces.delete(email: email)
  rescue SendgridToolkit::EmailDoesNotExist
    false
  end

  def remove_from_spam_list(email)
    return false unless can_access_sendgrid?
    spam_reports.delete(email: email)
  rescue SendgridToolkit::EmailDoesNotExist
    false
  end

  def smtp_alive?(host, port)
    Net::SMTP.start(host, port) do |smtp|
      smtp.enable_starttls_auto
      smtp.ehlo(Socket.gethostname)
      smtp.finish
    end
    true
  rescue StandardError
    false
  end

  private

  def spam_reports
    SendgridToolkit::SpamReports.new(user_name, password)
  end

  def bounces
    SendgridToolkit::Bounces.new(user_name, password)
  end

  def can_access_sendgrid?
    user_name && password
  end

  def user_name
    smtp_settings[:user_name]
  end

  def password
    smtp_settings[:password]
  end

  def smtp_settings
    Rails.configuration.action_mailer.smtp_settings || {}
  end
end
