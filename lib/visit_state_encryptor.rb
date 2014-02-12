class VisitStateEncryptor
  def initialize(key)
    @crypt = ActiveSupport::MessageEncryptor.new(key)
  end

  def encrypt(visit)
    @crypt.encrypt_and_sign(visit)
  end

  def decrypt(encrypted_visit)
    @crypt.decrypt_and_verify(encrypted_visit)
  end
end
