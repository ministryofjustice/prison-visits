require 'spec_helper'

describe PrisonVisits2::Application.config do
  it "sets a cookie with the right parameters" do
    subject.session_store.should == ActionDispatch::Session::CookieStore
    # secure: false -> true gets set by the initializer.
    subject.session_options.should == {key: "pvbs", expire_after: 20.minutes, httponly: true, cookie_only: true, secure: false, max_age: '1200'}
  end
end
