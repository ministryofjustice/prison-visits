require 'spec_helper'

describe Prisoner do
  let(:prisoner) do
    Prisoner.new(first_name: 'Jimmy', last_name: 'Fingers', date_of_birth: '1980-01-01', number: 'c2341em', prison_name: 'Durham')
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
end
