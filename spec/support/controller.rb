shared_examples "a browser without a session present" do
  it "redirects the user to the prisoner details page" do
    session.clear
    cookies['cookies-enabled'] = 1
    request.stub(ssl?: true)

    post :update
    response.should redirect_to(edit_prisoner_details_path)
  end
end

shared_examples "a session timed out" do
  it "displays an error notice" do
    session.clear
    cookies['cookies-enabled'] = 1
    request.stub(ssl?: true)

    post :update
    response.should redirect_to(edit_prisoner_details_path)
    flash.notice.should == 'Your session timed out because no information was entered for more than 20 minutes.'
  end
end
