require 'spec_helper'

describe PrisonerDetailsController do
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

  context "cookies are disabled" do
    it "redirects the user to a page telling them that they won't be able to use the site" do
      get :edit
      response.should be_success

      post :update, prisoner_hash
      response.should redirect_to(cookies_disabled_path)
    end
  end
end
