require 'rails_helper'

RSpec.describe PrisonVisits2::Application.config do
  it "uses the session cookie store" do
    expect(subject.session_store).to eq(ActionDispatch::Session::CookieStore)
  end

  it "uses pvbs as key" do
    expect(subject.session_options).to include(key: "pvbs")
  end

  it "sets the session expiry" do
    expect(subject.session_options).to include(expire_after: 20.minutes)
  end
end
