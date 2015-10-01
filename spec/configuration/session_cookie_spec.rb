require 'rails_helper'

RSpec.describe PrisonVisits2::Application.config do
  it "sets a cookie with the right parameters" do
    expect(subject.session_store).to eq(ActionDispatch::Session::CookieStore)
    # secure: false -> true gets set by the initializer.
    expect(subject.session_options).to eq({key: "pvbs", expire_after: 20.minutes, httponly: true, cookie_only: true, secure: false, domain: nil})
  end
end
