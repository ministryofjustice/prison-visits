shared_examples "a killswitch-enabled controller" do
  context "killswitch enabled" do
    it "resets an instant booking visit" do
      allow(subject).to receive(:killswitch_active?).and_return(true)
      expect {
        get :edit
        expect(response).to redirect_to edit_prisoner_details_path
      }.to change { session }
    end
  end
end
