require 'spec_helper'

describe Visit do
  it "restricts the number of visitors" do
    v = Visit.new
    v.visitors = []
    v.should_not be_valid
    
    v.visitors = [Visitor.new] * 7
    v.should_not be_valid
    
    v.visitors = [Visitor.new] * 6
    v.should be_valid
  end
end
