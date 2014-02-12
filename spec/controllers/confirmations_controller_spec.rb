require 'spec_helper'

describe ConfirmationsController do
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

  let :encryptor do
    VisitStateEncryptor.new(SecureRandom.hex)
  end

  before :each do
    controller.should_receive(:encryptor).at_least(1).and_return(encryptor)
  end

  it "resurrects the visit" do
    get :new, state: encryptor.encrypt(visit)
    subject.booked_visit.should.equal? visit
  end

  context "a confirmation email is sent" do
    before :each do
      controller.should_receive(:booked_visit).and_return(visit)
      PrisonMailer.should_receive(:booking_receipt_email).once
    end

    it "sends an e-mail to the user with a booked slot" do
      VisitorMailer.should_receive(:booking_confirmed_email).once
      post :create, confirmation: { slot: 1 }
      response.should redirect_to(confirmation_path)
    end

    it "sends an e-mail to the user when there are no slots available" do
      VisitorMailer.should_receive(:booking_rejected_email).once
      post :create, confirmation: { slot: 'none' }
      response.should redirect_to(confirmation_path)
    end
  end

  it "bails out if the state is corrupt or not present" do
    get :new
    expect {
      subject.booked_visit
    }.to raise_error(StandardError)

    get :new, state: 'bad state'
    expect {
      subject.booked_visit
    }.to raise_error(StandardError)
  end
end
