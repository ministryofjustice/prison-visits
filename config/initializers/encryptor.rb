MESSAGE_ENCRYPTOR = \
if key = ENV['MESSAGE_ENCRYPTOR_SECRET_KEY']
  ActiveSupport::MessageEncryptor.new(Base64.decode64(key))
else
  if Rails.env.production? && File.basename($0) != 'rake'
    raise "Missing MESSAGE_ENCRYPTOR_SECRET_KEY"
  else
    ActiveSupport::MessageEncryptor.new("TROLOLOLOLO" * 10)
  end
end


