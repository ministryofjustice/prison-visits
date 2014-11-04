require 'spec_helper'

describe VisitController do
  render_views

  before :each do
    controller.stub(:service_domain => 'lol.biz.info')
    request.stub(:ssl? => true)
  end

  context "always" do
    let :visit_id do
      SecureRandom.hex
    end

    it "displays the status of a visit not yet created" do
      controller.metrics_logger.should_receive(:visit_status).with(visit_id).twice.and_return(false)
      get :status, id: visit_id 
      response.status.should == 200
    end

    it "displays the status of an unprocessed visit" do
      controller.metrics_logger.should_receive(:visit_status).with(visit_id).and_return(:pending)
    end

    it "displays the status of a confirmed visit" do
      controller.metrics_logger.should_receive(:visit_status).with(visit_id).and_return(:confirmed)
    end

    it "displays the status of a rejected visit" do
      controller.metrics_logger.should_receive(:visit_status).with(visit_id).and_return(:rejected)
    end

    after :each do
      get :status, id: visit_id
      response.should be_success
    end
  end

  describe "abandon ship!" do
    before :each do
      session[:visit] = Visit.new(prisoner: Prisoner.new(prison_name: 'Alcatraz'))
    end

    it "should clear out the session" do
      get :abandon
      session[:visit].should be_nil
    end
  end
end
