require 'spec_helper'

describe Prisoner do
  let(:prisoner) do
    Prisoner.new(full_name: 'Jimmy Fingers', date_of_birth: '1980-01-01', number: 'c2341em', prison_name: 'Durham')
  end 

  it "must be valid" do
    prisoner.should be_valid
  end

  [:full_name, :date_of_birth, :prison_name].each do |field| 
    it "must fail if #{field} is not valid" do
      prisoner.send("#{field}=", '')
      prisoner.should_not be_valid
    end
  end 
end
