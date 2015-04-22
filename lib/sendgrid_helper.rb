module SendgridHelper
  def self.spam_reported?(email)
    handle_response(spam_reported_url(email))
  end

  def self.bounced?(email)
    handle_response(bounced_url(email))
  end

  def self.spam_reported_url(email)
    "https://sendgrid.com/api/spamreports.get.json?api_user=#{ENV['SMTP_USERNAME']}&api_key=#{ENV['SMTP_PASSWORD']}&email=#{email}"
  end

  def self.bounced_url(email)
    "https://sendgrid.com/api/bounces.get.json?api_user=#{ENV['SMTP_USERNAME']}&api_key=#{ENV['SMTP_PASSWORD']}&email=#{email}"
  end

  def self.handle_response(url)
    body = Curl::Easy.perform(url).body_str
    if response = JSON.parse(body)
      return false if response.is_a?(Hash) && response[:error]
      response.size > 0
    end
  rescue Curl::Err::CurlError, JSON::ParserError => e
    false
  end

  def self.smtp_alive?(host)
    Net::SMTP.start(host, 587) do |smtp|
      smtp.enable_starttls_auto
      smtp.ehlo(Socket.gethostname)
      smtp.finish
    end
    true
  rescue
    false
  end
end
