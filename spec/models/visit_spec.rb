require 'spec_helper'

describe Visit do
  it "restricts the number of visitors" do
    v = Visit.new
    v.slots = [Slot.new] * 3

    v.visitors = []
    v.should_not be_valid
    
    v.visitors = [Visitor.new] * 7
    v.should_not be_valid
    
    v.visitors = [Visitor.new] * 6
    v.should be_valid
  end

  it "restricts the number of slots" do
    v = Visit.new
    v.visitors = [Visitor.new]

    v.slots = []
    v.should_not be_valid

    (1..3).each do |t|
      v.slots = [Slot.new] * t
      v.should be_valid
    end

    v.slots = [Slot.new] * 4
    v.should_not be_valid
  end
end
