require 'spec_helper'
require 'visit_state_encryptor'

describe VisitStateEncryptor do
  let :subject do
    VisitStateEncryptor.new(SecureRandom.hex)
  end

  let :visit do
    Visit.new.tap do |v|
      v.slots = [Slot.new(date: Date.new(2013, 7, 7), times: "1330-1530")]
      v.prisoner = Prisoner.new.tap do |p|
        p.date_of_birth = Date.new(2013, 6, 30)
        p.first_name = 'Jimmy'
        p.last_name = 'Fingers'
      end
      v.visitors = [Visitor.new(email: 'sample@email.lol', date_of_birth: Date.new(1918, 11, 11))]
    end
  end

  it "decrypts the encrypted message" do
    encrypted = subject.encrypt(visit)
    decrypted = subject.decrypt(encrypted)

    visit.should.equal? decrypted
  end
end
