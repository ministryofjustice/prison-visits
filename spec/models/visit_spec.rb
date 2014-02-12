require 'spec_helper'

describe Visit do
  it "restricts the number of visitors" do
    v = Visit.new(visit_id: SecureRandom.hex)

    v.visitors = []
    v.valid?(:date_and_time).should be_false
    
    v.visitors = [Visitor.new] * 7
    v.valid?(:date_and_time).should be_false
    
    v.visitors = [Visitor.new] * 6
    v.should be_valid
  end

  it "restricts the number of slots" do
    v = Visit.new(visit_id: SecureRandom.hex)

    v.slots = []
    v.valid?(:date_and_time).should be_false

    (1..3).each do |t|
      v.slots = [Slot.new] * t
      v.valid?(:date_and_time).should be_true
    end

    v.slots = [Slot.new] * 4
    v.valid?(:date_and_time).should be_false
  end

  it "requires a visit_id" do
    Visit.new do |visit|
      expect {
        visit.visit_id = SecureRandom.hex
      }.to change { visit.valid?(:visit_id) }
    end
  end
end
