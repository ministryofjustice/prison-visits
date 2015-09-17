require 'zmarshal'

key_length = 88
key = ENV.fetch('MESSAGE_ENCRYPTOR_SECRET_KEY') { 'a' * key_length }
MESSAGE_ENCRYPTOR = ActiveSupport::MessageEncryptor.new \
  Base64.decode64(key), serializer: ZMarshal
