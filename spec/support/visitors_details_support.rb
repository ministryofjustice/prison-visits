shared_examples "a visitor data manipulator with valid data" do
  context "given prisoner data in the session" do
    let :add_visitor_hash do
      {
        visit: {
          visitor: [{}]
        },
        next: 'Add another visitor'
      }
    end

    let :remove_visitor_hash do
      {
        visit: {
          visitor: [{}, {}]
        },
        next: 'remove-1'
      }
    end

    let :remove_visitor_hash2 do
      {
        visit: {
          visitor: [{_destroy: 1}, {}]
        },
        next: ''
      }
    end

    it "displays a form for editing visitor information" do
      get :edit
      response.should be_success
    end

    it "adds and then removes a visitor from the session" do
      get :edit
      expect {
        post :update, add_visitor_hash
        response.should redirect_to controller.this_path
      }.to change { session[:visit].visitors.size }.by(1)

      expect {
        post :update, remove_visitor_hash
        response.should redirect_to controller.this_path
      }.to change { session[:visit].visitors.size }.by(-1)
    end

    it "removes a visitor from the session using a hash value" do
      get :edit
      session[:visit].visitors << Visitor.new

      expect {
        post :update, remove_visitor_hash
        response.should redirect_to controller.this_path
      }.to change { session[:visit].visitors.size }.by(-1)
    end
  end
end

shared_examples "a visitor data manipulator with invalid data" do
  context "given invalid visitor information" do
    let :bad_visitor_hash do
      {
        visit: {
          visitor: [{}]
        },
        next: ''
      }
    end
    
    it "doesn't update visitor information and redirects back to the form" do
      get :edit
      expect {
        post :update, bad_visitor_hash
        response.should redirect_to controller.this_path
      }.not_to change { session[:visit].visitors.first.first_name }
    end
  end

  context "given too many visitors" do
    let(:visitor_hash) do
      {
        visit: {
          visitor: single_visitor_hash * 7
        },
        next: ''
      }
    end

    it "rejects the submission if there are too many visitors" do
      post :update, visitor_hash
      response.should redirect_to(controller.this_path)
      session[:visit].valid?(:visitors_set).should be_false
    end
  end

  context "given too many adult visitors" do
    let(:visitor_hash) do
      {
        visit: {
          visitor: [
                    single_visitor_hash,
                    [
                     first_name: 'John',
                     last_name: 'Denver',
                     :'date_of_birth(3i)' => '31',
                     :'date_of_birth(2i)' => '12',
                     :'date_of_birth(1i)' => '1943'
                    ] * 3
                   ].flatten
        },
        next: ''
      }
    end

    it "rejects the submission if there are too many adult visitors" do
      post :update, visitor_hash
      response.should redirect_to(controller.this_path)
      session[:visit].valid?(:visitors_set).should be_false
    end
  end
end
