require 'spec_helper'

describe Deferred::VisitsController do
  render_views

  before :each do
    cookies['cookies-enabled'] = 1
  end

  it_behaves_like "a browser without a session present"
  it_behaves_like "a session timed out"

  context "given correct data" do
    let :mock_metrics_logger do
      MockMetricsLogger.new
    end

    before :each do
      Timecop.freeze(Time.local(2013, 12, 1, 12, 0))
      ActionMailer::Base.deliveries.clear
      subject.stub(:metrics_logger).and_return(mock_metrics_logger)

      session[:visit] = Visit.new.tap do |v|
        v.visit_id = SecureRandom.hex
        v.prisoner = Prisoner.new.tap do |p|
          p.first_name = 'Jimmy'
          p.last_name = 'Harris'
          p.number = 'aa1111aa'
          p.prison_name = 'Rochester'
          p.date_of_birth = Date.new(1975, 1, 1)
        end

        v.visitors = [Visitor.new.tap do |vi|
                        vi.first_name = 'Morvern'
                        vi.last_name = 'Callar'
                        vi.email = 'email@system.lol'
                        vi.index = 0
                        vi.phone = '01234567890'
                        vi.date_of_birth = Date.today - 20.years
                      end]

        v.slots = [Slot.new(date: '2013-12-06', times: '0945-1115'), Slot.new, Slot.new]
      end
    end

    it "displays a summary" do
      get :edit
      response.should be_success
    end

    it "sends out emails" do
      mock_metrics_logger.should_receive(:record_visit_request).with(session[:visit])

      PrisonMailer.any_instance.should_receive(:sender).and_return('test@example.com')
      VisitorMailer.any_instance.should_receive(:sender).and_return('test@example.com')

      post :update
      response.should redirect_to(deferred_visit_path)

      ActionMailer::Base.deliveries.map(&:subject).should == ['Visit request for Jimmy Harris on Friday  6 December',
                                                              "Not booked yet: we've received your visit request for 6 December 2013"]
    end
  end
end
