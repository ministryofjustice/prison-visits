require 'spec_helper'

describe Visitor do
  it "validates the first visitor as a lead visitor" do
    Visitor.new(index: 0).tap do |v|
      v.full_name = 'Jimmy Fingers'
      v.should_not be_valid

      v.date_of_birth = "1986-04-20"
      v.should_not be_valid

      v.email = 'jimmy@fingers.com'
      v.should be_valid
    end
  end

  it "validates every other visitor as a non-lead visitor" do
    (1..5).each do |i|
      Visitor.new(index: i).tap do |v|
        v.full_name = 'Jimmy Fingers'
        v.should_not be_valid
        
        v.date_of_birth = "1986-04-20"
        v.should be_valid
        
        v.email = 'anything'
        v.should_not be_valid
      end
    end
  end
end
