require 'zmarshal'

class Encryptor
  def initialize(key)
    @encryptors = [ActiveSupport::MessageEncryptor.new(key, serializer: ZMarshal), ActiveSupport::MessageEncryptor.new(key)]
  end

  def encrypt_and_sign(value)
    @encryptors.first.encrypt_and_sign(value)
  end

  def decrypt_and_verify(value)
    @encryptors.each do |e|
      begin
        return e.decrypt_and_verify(value)
      rescue Zlib::DataError
        STATSD_CLIENT.increment('pvb.app.legacy_encryptor')
        next
      end
    end
  end
end
