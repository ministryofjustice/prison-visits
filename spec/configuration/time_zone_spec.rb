require 'spec_helper'

describe Time do
  it "sets the time zone to London" do
    Time.zone.name.should == 'London'
  end
end
