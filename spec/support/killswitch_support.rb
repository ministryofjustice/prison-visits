shared_examples "a killswitch-enabled controller" do
  context "killswitch enabled" do
    it "resets an instant booking visit" do
      subject.stub(killswitch_active?: true)
      expect {
        get :edit
        response.should redirect_to edit_prisoner_details_path
      }.to change { session }
    end
  end
end
