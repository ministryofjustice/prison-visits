RSpec.shared_examples "a browser without a session present" do
  it "redirects the user to the prisoner details page" do
    session.clear
    cookies['cookies-enabled'] = 1
    allow(request).to receive(:ssl?).and_return(true)

    post :update
    expect(response).to redirect_to(edit_prisoner_details_path)
  end
end

RSpec.shared_examples "a session timed out" do
  it "displays an error notice" do
    session.clear
    cookies['cookies-enabled'] = 1
    allow(request).to receive(:ssl?).and_return(true)

    post :update
    expect(response).to redirect_to(edit_prisoner_details_path)
    expect(flash.notice).to eq('Your session timed out because no information was entered for more than 20 minutes.')
  end
end
