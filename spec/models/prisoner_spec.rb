require 'rails_helper'

RSpec.describe Prisoner do
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
    expect(prisoner).to be_valid
  end

  [:first_name, :last_name, :date_of_birth, :prison_name, :number].each do |field|
    it "must fail if #{field} is not valid" do
      prisoner.send("#{field}=", '')
      expect(prisoner).not_to be_valid
    end
  end

  it "requires a valid name" do
    prisoner.first_name = '<Jeremy'
    expect(prisoner).not_to be_valid

    prisoner.last_name = 'Jeremy>'
    expect(prisoner).not_to be_valid
  end

  it "requires a first name under 30 bytes" do
    prisoner.first_name = "An awfully long name, far too long to be considered valid, may in fact be a monologue"
    expect(prisoner).not_to be_valid
  end

  it "requires a last name under 30 bytes" do
    prisoner.last_name =  "It could even be a secret message that someone is trying to get to a prison guard"
    expect(prisoner).not_to be_valid
  end

  ['123', 'abc', 'a123bc', 'aaa1234bc', 'w5678xyz'].each do |number|
    it "must fail if prisoner number is #{number}" do
      prisoner.send('number=', number)
      expect(prisoner).not_to be_valid
    end
  end

  it "must pass if prisoner number is valid" do
    expect(prisoner.number.size).to eq(7)
    expect(prisoner).to be_valid
  end

  it "displays a full name" do
    expect(prisoner.full_name).to eq('Jimmy Harris')
  end

  it "returns the age of the prisoner" do
    expect(prisoner.age).to eq(30)
    prisoner.date_of_birth = nil
    expect(prisoner.age).to be_nil
  end

  it 'generates an initial from the last name' do
    expect(prisoner.last_initial).to eq('H')
  end
end
