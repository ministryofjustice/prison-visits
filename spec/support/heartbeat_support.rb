shared_examples "a service is broken" do |service|
  it "returns a HTTP Bad Gateway status" do
    get :healthcheck
    assert_response(:bad_gateway, response.status)
  end

  it "reports #{service} as inaccessible" do
    get :healthcheck
    parsed_body = JSON.parse(response.body)
    expect(parsed_body['checks'][service]).to be_false
  end
end
