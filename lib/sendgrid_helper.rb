module SendgridHelper
  def self.spam_reported?(email)
    body = Curl::Easy.perform(spam_reported_url(email)).body_str
    if response = JSON.parse(body)
      return false if response.is_a?(Hash) && response[:error]
      response.size > 0
    end
  rescue Curl::Err::CurlError, JSON::ParserError => e
    false
  end

  def self.spam_reported_url(email)
    "https://sendgrid.com/api/spamreports.get.json?api_user=#{ENV['SMTP_USERNAME']}&api_key=#{ENV['SMTP_PASSWORD']}&email=#{email}"
  end
end
