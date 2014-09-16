shared_examples "a controller that can resurrect a visit" do
  before :each do
    controller.stub(:metrics_logger).and_return(mock_metrics_logger)
    controller.stub(:reject_untrusted_ips!)
  end

  it "resurrects the visit" do
    controller.should_receive(:logstasher_add_visit_id).with(visit.visit_id)
    mock_metrics_logger.should_receive(:record_link_click)
    mock_metrics_logger.should_receive(:processed?) do |v|
      v.should.eql? visit
      false
    end
    get :new, state: MESSAGE_ENCRYPTOR.encrypt_and_sign(visit)
    subject.booked_visit.should.equal? visit
    response.should be_success
    response.should render_template('confirmations/new')
  end

  it "doesn't resurrect a visit which has already been booked" do
    sample_visit.tap do |visit|
      mock_metrics_logger.should_receive(:record_link_click)
      mock_metrics_logger.should_receive(:processed?) do |v|
        v.should.eql? visit
        true
      end
      get :new, state: MESSAGE_ENCRYPTOR.encrypt_and_sign(visit)
      response.should be_success
      response.should render_template('confirmations/_already_booked')
    end
  end

  ['Hatfield (moorland Open)', 'Highpoint', 'Albany', 'Parkhurst'].each do |prison_name|
    it "resurrects a visit with a old prison name (#{prison_name}) to avoid a runtime exception" do
      sample_visit.tap do |visit|
        visit.prisoner.prison_name = prison_name
        controller.should_receive(:logstasher_add_visit_id).with(visit.visit_id)
        mock_metrics_logger.should_receive(:record_link_click)
        mock_metrics_logger.should_receive(:processed?) do |v|
          v.should.eql? visit
          false
        end
        get :new, state: MESSAGE_ENCRYPTOR.encrypt_and_sign(visit)
        response.should be_success
        response.should render_template('confirmations/new')
      end
    end
  end

  it "bails out if the state is not present" do
    get :new
    response.status.should == 400
    response.should render_template('confirmations/_bad_state')
  end
  
  it "bails out if the state is corrupt" do
    get :new, state: 'bad state'
    response.status.should == 400
    response.should render_template('confirmations/_bad_state')
  end
end
