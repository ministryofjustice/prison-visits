require 'spec_helper'

describe Rails.application.config.filter_parameters do
  it "filters out sensitive information" do
    subject.should == [:password, :first_name, :last_name, :number]
  end
end
