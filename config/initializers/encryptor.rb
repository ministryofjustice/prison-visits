require 'zmarshal'

MESSAGE_ENCRYPTOR_SECRET_KEY = ENV.fetch('MESSAGE_ENCRYPTOR_SECRET_KEY')

MESSAGE_ENCRYPTOR = ActiveSupport::MessageEncryptor.new \
  Base64.decode64(MESSAGE_ENCRYPTOR_SECRET_KEY), serializer: ZMarshal
