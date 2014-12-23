require 'spec_helper'

describe VisitController do
  render_views

  before :each do
    controller.stub(:service_domain => 'lol.biz.info')
    request.stub(:ssl? => true)
  end

  let :visit_id do
    sample_visit.visit_id
  end

  let :token do
    MESSAGE_ENCRYPTOR.encrypt_and_sign(sample_visit)
  end

  context "always" do
    it "displays the status of a visit not yet created" do
      controller.metrics_logger.should_receive(:visit_status).with(visit_id).twice.and_return(false)
      get :status, id: visit_id, state: token
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
      get :status, id: visit_id, state: token
      response.should be_success
    end
  end

  context "legacy email handling" do
    it "displays the status of the visit" do
      get :status, id: visit_id
      response.status.should == 200
    end
  end

  context "cancelled visits" do
    it "displays the status of a cancelled visit request" do
      controller.metrics_logger.should_receive(:visit_status).with(visit_id).and_return(:request_cancelled)
    end

    it "displays the status of a cancelled visit" do
      controller.metrics_logger.should_receive(:visit_status).with(visit_id).and_return(:visit_cancelled)
    end

    after :each do
      get :status, id: visit_id
      response.body.should include("cancelled")
    end
  end

  context "cancel an existing visit" do
    let :encrypted_visit do
      MESSAGE_ENCRYPTOR.encrypt_and_sign(sample_visit)
    end

    it "cancels a pending visit request" do
      controller.metrics_logger.should_receive(:visit_status).with(sample_visit.visit_id).and_return(:pending)
    end

    it "cancels a confirmed visit request" do
      controller.metrics_logger.should_receive(:visit_status).with(sample_visit.visit_id).and_return(:confirmed)
    end

    after :each do
      post :update_status, id: sample_visit.visit_id, state: encrypted_visit
      response.should redirect_to(visit_status_path(sample_visit.visit_id))
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
