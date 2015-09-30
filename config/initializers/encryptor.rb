key = ENV.fetch('MESSAGE_ENCRYPTOR_SECRET_KEY') { 'a' * 88 }
MESSAGE_ENCRYPTOR = TokenSerializer.new(key)
