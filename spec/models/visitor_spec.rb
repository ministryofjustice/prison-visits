require 'spec_helper'

describe Visitor do
  it "validates the first visitor as a lead visitor" do
    Visitor.new(index: 0).tap do |v|
      v.first_name = 'Jimmy'
      v.should_not be_valid

      v.last_name = 'Fingers'
      v.should_not be_valid

      v.date_of_birth = "1986-04-20"
      v.should_not be_valid

      v.email = 'jimmy@fingers.com'
      v.should_not be_valid
      
      v.phone = '01344 123456'
      v.should be_valid
    end
  end

  it "validates every other visitor as an additional visitor" do
    (1..5).each do |i|
      Visitor.new(index: i).tap do |v|
        v.first_name = 'Jimmy'
        v.should_not be_valid

        v.last_name = 'Fingers'
        v.should_not be_valid
        
        v.type = 'adult'
        v.should be_valid
        
        v.email = 'anything'
        v.should_not be_valid
      end
    end
  end
end
