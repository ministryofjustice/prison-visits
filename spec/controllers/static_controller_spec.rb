require 'spec_helper'

describe StaticController do
  it "returns a list of prison e-mails as CSV" do
    get :prison_emails, format: :csv
    response.should be_success
    response.body.split(/\n/).size == 98
  end
end
