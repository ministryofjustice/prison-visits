class TokenSerializer
  extend Forwardable

  def initialize(key)
    @encryptor = ActiveSupport::MessageEncryptor.new(
      Base64.decode64(key),
      serializer: CompressedMarshaller.new
    )
    @hasher = RecursiveHasher.new
  end

  def encrypt_and_sign(visit)
    @encryptor.encrypt_and_sign(@hasher.export(visit))
  end

  def decrypt_and_verify(ciphertext)
    decrypted = @encryptor.decrypt_and_verify(ciphertext)
    if decrypted.is_a?(Hash)
      @hasher.import(decrypted, Visit)
    else
      decrypted
    end
  end
end
