require 'encryptor'

MESSAGE_ENCRYPTOR = \
if key = ENV['MESSAGE_ENCRYPTOR_SECRET_KEY']
  Encryptor.new(Base64.decode64(key))
else
  if Rails.env.production? && File.basename($0) != 'rake'
    raise "Missing MESSAGE_ENCRYPTOR_SECRET_KEY"
  else
    Encryptor.new("TROLOLOLOLO" * 10)
  end
end


