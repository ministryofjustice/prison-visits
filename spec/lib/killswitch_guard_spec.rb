require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    include KillswitchGuard

    def index
      render text: 'OK'
    end
  end

  context "killswitch enabled" do
    it "resets the session and redirects to step one" do
      allow(subject).to receive(:killswitch_active?).and_return(true)
      expect(controller).to receive(:reset_session)
      get :index
      expect(response).to redirect_to edit_prisoner_details_path
    end
  end

  context "killswitch disabled" do
    it "doesn't do anything" do
      allow(subject).to receive(:killswitch_active?).and_return(false)
      expect(controller).to receive(:reset_session).never
      get :index
      expect(response).to be_success
    end
  end
end
