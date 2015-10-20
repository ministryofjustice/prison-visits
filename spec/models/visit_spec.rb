require 'rails_helper'

RSpec.describe Visit do
  let :adult_visitor do
    Visitor.new(date_of_birth: (Time.zone.today - 19.years))
  end

  let :child_visitor do
    Visitor.new(date_of_birth: (Time.zone.today - 10.years))
  end

  let :sample_visit do
    Visit.new(visit_id: SecureRandom.hex, prisoner: Prisoner.new(prison_name: 'Rochester'))
  end

  describe 'delegation' do
    it 'exposes the prison via the prisoner' do
      expect(sample_visit.prison.to_json).to eq(Prison.find('Rochester').to_json)
    end

    it 'exposes some prison attributes via the prisoner' do
      expect(sample_visit.prison_name).to eq('Rochester')
      expect(sample_visit.prison_nomis_id).to eq('RCI')
      expect(sample_visit.prison_canned_responses).to be_truthy
      expect(sample_visit.prison_email).to eq('pvb.RCI@maildrop.dsd.io')
    end
  end

  it "restricts the number of visitors" do
    sample_visit.visitors = []
    expect(sample_visit.valid?(:visitors_set)).to be_falsey

    sample_visit.visitors = [child_visitor] * 7
    expect(sample_visit.valid?(:visitors_set)).to be_falsey

    sample_visit.visitors = [adult_visitor] * 1 + [child_visitor] * 5
    expect(sample_visit.valid?(:visitors_set)).to be_truthy
  end

  it "restricts the number of slots" do
    sample_visit.slots = []
    sample_visit.visitors = [adult_visitor]
    expect(sample_visit.valid?(:date_and_time)).to be_falsey

    (1..3).each do |t|
      sample_visit.slots = [Slot.new] * t
      expect(sample_visit.valid?(:date_and_time)).to be_truthy
    end

    sample_visit.slots = [Slot.new] * 4
    expect(sample_visit.valid?(:date_and_time)).to be_falsey
  end

  it 'is valid with three or fewer adult visitors' do
    3.times do
      sample_visit.visitors << double(age: 19)
    end
    expect(sample_visit.valid?(:visitors_set)).to be_truthy
  end

  it 'is invalid with more than three adult visitors' do
    4.times do
      sample_visit.visitors << double(age: 19)
    end
    expect(sample_visit.valid?(:visitors_set)).to be_falsey
  end

  context "a prison which treats a child as an adult for seating purposes" do
    before do
      sample_visit.prison_name = 'Deerbolt'
      sample_visit.visitors = []
    end

    let(:group_with_adult) do
      [double(age: 19), double(age: 10),
       double(age: 10), double(age: 9)
      ].each { |v| sample_visit.visitors << v }
    end

    let(:group_of_children) do
      [double(age: 9), double(age: 10),
       double(age: 10), double(age: 9)
      ].each { |v| sample_visit.visitors << v }
    end

    it "requires at least one real adult" do
      group_with_adult
      expect(sample_visit.valid?(:visitors_set)).to be_truthy
    end

    it "fails if there is not at least one adult" do
      group_of_children
      sample_visit.valid?
      expect(sample_visit.valid?(:visitors_set)).to be_falsey
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
    expect(sample_visit.adult?(adult_visitor)).to be_truthy
    expect(sample_visit.adult?(child_visitor)).to be_falsey
  end

  describe 'same_visit?' do
    it 'is true if two different visits have the same visit_id' do
      a = sample_visit
      b = sample_visit.dup
      expect(a).not_to eq(b)
      expect(a).to be_same_visit(b)
    end

    it 'is false if two different visits have a different visit_id' do
      a = sample_visit
      b = sample_visit.dup
      b.visit_id = SecureRandom.hex
      expect(a).not_to be_same_visit(b)
    end
  end
end
