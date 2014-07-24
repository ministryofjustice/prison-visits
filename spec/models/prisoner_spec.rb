require 'spec_helper'

describe Prisoner do
  let :prisoner do
    Prisoner.new.tap do |p|
      p.first_name = 'Jimmy'
      p.last_name = 'Harris'
      p.date_of_birth = 30.years.ago
      p.number = 'c2341em'
      p.prison_name = 'Rochester'
    end
  end 

  it "must be valid" do
    prisoner.should be_valid
  end

  [:first_name, :last_name, :date_of_birth, :prison_name, :number].each do |field| 
    it "must fail if #{field} is not valid" do
      prisoner.send("#{field}=", '')
      prisoner.should_not be_valid
    end
  end

  it "requires a valid name" do
    prisoner.first_name = '<Jeremy'
    prisoner.should_not be_valid

    prisoner.last_name = 'Jeremy>'
    prisoner.should_not be_valid
  end

  ['123', 'abc', 'a123bc', 'aaa1234bc', 'w5678xyz'].each do |number|
    it "must fail if prisoner number is #{number}" do
      prisoner.send('number=', number)
      prisoner.should_not be_valid
    end
  end

  it "must pass if prisoner number is valid" do
    prisoner.number.should have(7).characters
    prisoner.should be_valid
  end

  it "displays a full name" do
    prisoner.full_name.should == 'Jimmy Harris'
  end

  it "returns the age of the prisoner" do
    prisoner.age.should == 30
    prisoner.date_of_birth = nil
    prisoner.age.should be_nil
  end
end
