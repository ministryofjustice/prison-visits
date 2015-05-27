require 'rails_helper'

RSpec.describe PrisonerDetailsController, type: :controller do
  render_views

  let(:prisoner_hash) do
    {
      prisoner: {
        first_name: 'Jimmy',
        last_name: 'Harris',
        :'date_of_birth(3i)' => '20',
        :'date_of_birth(2i)' => '04',
        :'date_of_birth(1i)' => '1986',
        number: 'g3133ff',
        prison_name: 'Rochester'
      }
    }
  end

  it_behaves_like "a browser without a session present"
  it_behaves_like "a session timed out"

  context "always" do
    it "creates a new session" do
      controller.new_session.tap do |visit|
        expect(visit.visit_id).to be_a String
        expect(visit.visit_id.size).to eq(32)

        expect(visit.prisoner).to be_a Prisoner

        expect(visit.visitors).to eq([])

        expect(visit.slots).to eq([])
      end
    end
  end

  context "when cookies are disabled" do
    it "redirects the user to a page telling them that they won't be able to use the site" do
      get :edit
      expect(response).to be_success

      post :update, prisoner_hash
      expect(response).to redirect_to(cookies_disabled_path)
    end
  end

  context "cookies are enabled" do
    before :each do
      cookies['cookies-enabled'] = 1
      allow(request).to receive(:ssl?).and_return(true)
    end

    it "renders the form for entering prisoner details, and assigns the session" do
      expect(SecureRandom).to receive(:hex).and_return(visit_id = 'LOL' * 10)
      expect(controller).to receive(:logstasher_add_visit_id).with(visit_id)
      expect {
        get :edit
        expect(response).to be_success
      }.to change { session[:visit] }
    end

    it "sets the 'cookies-enabled' cookie" do
      allow(controller).to receive(:service_domain).and_return('lol.biz.info')
      get :edit
      expect(response).to be_success
      response['Set-Cookie'].tap do |c|
        expect(c).to match(/secure/i)
        expect(c).to match(/httponly/i)
        expect(c).to match(/domain=lol.biz.info/i)
      end
    end

    context "given valid prisoner details" do
      before :each do
        get :edit
      end

      it "updates prisoner details and redirects to the email flow" do
        post :update, prisoner_hash
        expect(response).to redirect_to(deferred_edit_visitors_details_path)
      end

      it "updates prisoner details and redirects to the email flow if the killswitch is active" do
        allow(subject).to receive(:killswitch_active?).and_return(true)
        post :update, prisoner_hash
        expect(response).to redirect_to(deferred_edit_visitors_details_path)
      end

      it "updates prisoner details and redirects to the api flow" do
        prisoner_hash[:prisoner].merge!(prison_name: 'Durham')

        post :update, prisoner_hash
        expect(response).to redirect_to(instant_edit_visitors_details_path)
      end

      it "updates prisoner details with bad date and redirects back" do
        bad_prisoner_hash = prisoner_hash.dup
        bad_prisoner_hash[:prisoner].except!(:'date_of_birth(3i)', :'date_of_birth(2i)', :'date_of_birth(1i)')
        post :update, bad_prisoner_hash
        expect(response).to redirect_to(edit_prisoner_details_path)
      end

      it "doesn't accept the year as having two digits" do
        prisoner_hash[:prisoner][:'date_of_birth(3i)'] = '5'
        prisoner_hash[:prisoner][:'date_of_birth(2i)'] = '2'
        prisoner_hash[:prisoner][:'date_of_birth(1i)'] = '12'
        post :update, prisoner_hash
        expect(response).to redirect_to(edit_prisoner_details_path)
      end

      context "whitespace trimming" do
        it "removes whitespace from strings" do
          post :update, { prisoner: { first_name: ' Jimmy ', last_name: ' Harris ' } }
          expect(controller.visit.prisoner.first_name).to eq('Jimmy')
          expect(controller.visit.prisoner.last_name).to eq('Harris')
        end
      end
    end
  end
end

