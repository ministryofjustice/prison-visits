require 'spec_helper'

describe Encryptor do
  let :key do
    "LOL" * 20
  end

  subject do
    Encryptor.new(key)
  end

  it "encrypts objects with compression and decrypts it" do
    subject.decrypt_and_verify(subject.encrypt_and_sign(sample_visit)).should be_practically sample_visit
  end

  it "decrypts uncompressed visits" do
    legacy_encryptor = ActiveSupport::MessageEncryptor.new(key)
    ciphertext = legacy_encryptor.encrypt_and_sign(sample_visit)
    subject.decrypt_and_verify(ciphertext).should be_practically sample_visit
  end
end
