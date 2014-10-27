require 'spec_helper'

describe MetricsHelper do
  it "displays zero" do
    helper.display_interval(0).should == "0s"
  end

  it "displays a long time" do
    helper.display_interval(229418).should == "2d15h43m38s"
  end

  it "passes through nil" do
    helper.display_interval(nil).should be_nil
  end

  it "displays percentages" do
    helper.display_percent(1.0/3).should == "33.3"
    helper.display_percent(0.1).should == "10.0"
    helper.display_percent(0.0).should == "0.0"
  end
end
