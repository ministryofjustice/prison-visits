require 'rails_helper'

RSpec.describe Instant::VisitsController, type: :controller do
  render_views

  before :each do
    cookies['cookies-enabled'] = 1
  end

  it_behaves_like "a browser without a session present"
  it_behaves_like "a session timed out"
  it_behaves_like "a killswitch-enabled controller"

  context "given correct data" do
    let :mock_metrics_logger do
      MockMetricsLogger.new
    end

    before :each do
      Timecop.freeze(Time.local(2013, 12, 1, 12, 0))
      ActionMailer::Base.deliveries.clear
      allow(subject).to receive(:metrics_logger).and_return(mock_metrics_logger)

      session[:visit] = Visit.new.tap do |v|
        v.visit_id = SecureRandom.hex
        v.prisoner = Prisoner.new.tap do |p|
          p.first_name = 'Jimmy'
          p.last_name = 'Harris'
          p.number = 'aa1111aa'
          p.prison_name = 'Rochester'
          p.date_of_birth = Date.new(1975, 1, 1)
        end

        v.visitors = [Instant::Visitor.new.tap do |vi|
                        vi.first_name = 'Morvern'
                        vi.last_name = 'Callar'
                        vi.email = 'email@system.lol'
                        vi.index = 0
                        vi.date_of_birth = Date.today - 20.years
                      end]

        v.slots = [Slot.new(date: '2013-12-06', times: '0945-1115')]
      end
    end

    after :each do
      Timecop.return
    end

    it "displays a summary" do
      get :edit
      expect(response).to be_success
    end

    it "sends out emails" do
      expect(mock_metrics_logger).to receive(:record_instant_visit).with(session[:visit])
      state = controller.encryptor.encrypt_and_sign(session[:visit])
      allow(controller.encryptor).to receive(:encrypt_and_sign).and_return(state)

      expect_any_instance_of(VisitorMailer).to receive(:sender).and_return('test@example.com')

      post :update
      expect(response).to redirect_to(instant_show_visit_path(state: state))

      expect(ActionMailer::Base.deliveries.map(&:subject)).to eq(['Visit confirmation for 6 December 2013'])
    end

    it "displays the final page" do
      state = controller.encryptor.encrypt_and_sign(session[:visit])
      session.clear
      get :show, state: state
      expect(response).to be_success
    end
  end
end
