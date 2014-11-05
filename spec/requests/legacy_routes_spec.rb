require 'spec_helper'

describe "Legacy routes" do
  it "recognizes old routes" do
    get "/confirmation/new"
    expect(response).to redirect_to(new_deferred_confirmation_path)

    get "/prisoner-details"
    response.should redirect_to(edit_prisoner_details_path)
  end
end
