require 'spec_helper'

describe Visit do
  let :adult_visitor do
    Visitor.new(date_of_birth: (Date.today - 19.years))
  end

  let :child_visitor do
    Visitor.new(date_of_birth: (Date.today - 10.years))
  end

  let :sample_visit do
    Visit.new(visit_id: SecureRandom.hex, prisoner: Prisoner.new(prison_name: 'Rochester'))
  end

  it "restricts the number of visitors" do
    sample_visit.visitors = []
    expect(sample_visit.valid?(:visitors_set)).to be_false
    
    sample_visit.visitors = [child_visitor] * 7
    expect(sample_visit.valid?(:visitors_set)).to be_false
    
    sample_visit.visitors = [adult_visitor] * 1 + [child_visitor] * 5
    expect(sample_visit.valid?(:visitors_set)).to be_true
  end

  it "restricts the number of slots" do
    sample_visit.slots = []
    sample_visit.visitors = [adult_visitor]
    expect(sample_visit.valid?(:date_and_time)).to be_false

    (1..3).each do |t|
      sample_visit.slots = [Slot.new] * t
      expect(sample_visit.valid?(:date_and_time)).to be_true
    end

    sample_visit.slots = [Slot.new] * 4
    expect(sample_visit.valid?(:date_and_time)).to be_false
  end

  it "ensures that at most three adults can book a visit" do
    (1..3).each do |n|
      sample_visit.visitors = [double(age: 19)] * n
      expect(sample_visit.valid?(:visitors_set)).to be_true
    end
    sample_visit.visitors = [double(age: 19)] * 4
    expect(sample_visit.valid?(:visitors_set)).to be_false
  end

  context "given a prison which treats a child as an adult for seating purposes" do
    it "requires at least one real adult" do
      sample_visit.prisoner.prison_name = 'Deerbolt'
      sample_visit.visitors = []

      [double(age: 19),
       double(age: 10),
       double(age: 10),
       double(age: 9)].each do |visitor|
        sample_visit.visitors << visitor
        expect(sample_visit.valid?(:visitors_set)).to be_true
      end

      sample_visit.visitors << double(age: 10)
      expect(sample_visit.valid?(:visitors_set)).to be_false
    end
  end

  it "requires a visit_id" do
    Visit.new do |visit|
      expect {
        visit.visit_id = SecureRandom.hex
      }.to change { visit.valid?(:visit_id) }
    end
  end

  it "knows if a visitor is an adult or not" do
    expect(sample_visit.adult?(adult_visitor)).to be_true
    expect(sample_visit.adult?(child_visitor)).to be_false
  end
end
