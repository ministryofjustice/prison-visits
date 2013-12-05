require 'spec_helper'

describe Visitor do
  let :visitor do
    Visitor.new.tap do |v|
      v.first_name = 'Otto'
      v.last_name = 'Fibonacci'
      v.email = 'fibonacci@example.com'
      v.phone = '07776665555'
      v.date_of_birth = 30.years.ago.to_s
    end
  end

  it "validates the first visitor as a lead visitor" do
    Visitor.new(index: 0).tap do |v|
      v.first_name = 'Jimmy'
      v.should_not be_valid

      v.last_name = 'Fingers'
      v.should_not be_valid

      v.date_of_birth = Date.parse "1986-04-20"
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
        
        v.date_of_birth = Date.parse "1986-04-20"
        v.should be_valid
        
        v.email = 'anything'
        v.should_not be_valid
      end
    end
  end

  it "displays a full_name" do
    visitor.full_name.should == 'Otto Fibonacci'
  end

  it "knows if the visitor is an adult" do
    visitor.should be_adult
  end

  it "knows if the visitor is a child" do
    visitor.date_of_birth = 8.years.ago.to_s
    visitor.should be_child
  end

  it "returns the age of the visitor" do
    visitor.age.should == 30
    visitor.date_of_birth = nil
    visitor.age.should be_nil
  end
end
