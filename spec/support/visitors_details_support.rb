shared_examples "a visitor data manipulator" do
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
      expect {
        post :update, add_visitor_hash
        response.should redirect_to deferred_edit_visitors_details_path
      }.to change { session[:visit].visitors.size }.by(1)

      expect {
        post :update, remove_visitor_hash
        response.should redirect_to deferred_edit_visitors_details_path
      }.to change { session[:visit].visitors.size }.by(-1)
    end

    it "removes a visitor from the session using a hash value" do
      session[:visit].visitors << Visitor.new

      expect {
        post :update, remove_visitor_hash
        response.should redirect_to deferred_edit_visitors_details_path
      }.to change { session[:visit].visitors.size }.by(-1)
    end
  end
end
