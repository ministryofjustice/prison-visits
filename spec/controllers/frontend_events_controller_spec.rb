require 'rails_helper'

RSpec.describe FrontendEventsController, type: :controller do
  it "returns a success response" do
    post :create, event: { type: 'dummy' }
    expect(response).to be_success
  end
end
