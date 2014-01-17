require 'spec_helper'

describe Visit do
  it "restricts the number of visitors" do
    v = Visit.new

    v.visitors = []
    v.valid?(:date_and_time).should be_false
    
    v.visitors = [Visitor.new] * 7
    v.valid?(:date_and_time).should be_false
    
    v.visitors = [Visitor.new] * 6
    v.should be_valid
  end

  it "restricts the number of slots" do
    v = Visit.new

    v.slots = []
    v.valid?(:date_and_time).should be_false

    (1..3).each do |t|
      v.slots = [Slot.new] * t
      v.should be_valid
    end

    v.slots = [Slot.new] * 4
    v.valid?(:date_and_time).should be_false
  end
end
