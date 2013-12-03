require 'spec_helper'

describe PrisonVisits2::Application.config do
  it "sets a cookie with the right parameters" do
    subject.session_store.should == ActionDispatch::Session::CookieStore
    subject.session_options.should == {key: "pvbs", expire_after: 20.minutes, httponly: true, cookie_only: true}
  end
end
