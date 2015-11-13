require 'rails_helper'

RSpec.describe Visit do
  let(:adult_visitor) {
    Visitor.new(date_of_birth: (Time.zone.today - 19.years))
  }

  let(:child_visitor) {
    Visitor.new(date_of_birth: (Time.zone.today - 10.years))
  }

  subject {
    Visit.new(visit_id: SecureRandom.hex, prisoner: Prisoner.new(prison_name: 'Rochester'))
  }

  describe 'delegation' do
    it { expect(subject.prisoner?).to be_truthy }
    it { expect(subject.prisoner_number?).to be_falsey }
    it { expect(subject.prison_name?).to be_truthy }
    it { expect(subject.prison?).to be_truthy }
    it { expect(subject.prison_slots?).to be_truthy }

    it 'exposes the prison via the prisoner' do
      expect(subject.prison.to_json).to eq(Prison.find('Rochester').to_json)
    end

    it 'exposes some prison attributes via the prisoner' do
      expect(subject.prison_name).to eq('Rochester')
      expect(subject.prison_nomis_id).to eq('RCI')
      expect(subject.prison_email).to eq('pvb.RCI@maildrop.dsd.io')
    end
  end

  it "restricts the number of visitors" do
    subject.visitors = []
    expect(subject.valid?(:visitors_set)).to be_falsey

    subject.visitors = [child_visitor] * 7
    expect(subject.valid?(:visitors_set)).to be_falsey

    subject.visitors = [adult_visitor] * 1 + [child_visitor] * 5
    expect(subject.valid?(:visitors_set)).to be_truthy
  end

  it "restricts the number of slots" do
    subject.slots = []
    subject.visitors = [adult_visitor]
    expect(subject.valid?(:date_and_time)).to be_falsey

    (1..3).each do |t|
      subject.slots = [Slot.new] * t
      expect(subject.valid?(:date_and_time)).to be_truthy
    end

    subject.slots = [Slot.new] * 4
    expect(subject.valid?(:date_and_time)).to be_falsey
  end

  it 'is valid with three or fewer adult visitors' do
    3.times do
      subject.visitors << double(age: 19)
    end
    expect(subject.valid?(:visitors_set)).to be_truthy
  end

  it 'is invalid with more than three adult visitors' do
    4.times do
      subject.visitors << double(age: 19)
    end
    expect(subject.valid?(:visitors_set)).to be_falsey
  end

  context "a prison which treats a child as an adult for seating purposes" do
    before do
      subject.prison_name = 'Deerbolt'
      subject.visitors = []
    end

    let(:group_with_adult) do
      [double(age: 19), double(age: 10),
       double(age: 10), double(age: 9)
      ].each { |v| subject.visitors << v }
    end

    let(:group_of_children) do
      [double(age: 9), double(age: 10),
       double(age: 10), double(age: 9)
      ].each { |v| subject.visitors << v }
    end

    it "requires at least one real adult" do
      group_with_adult
      expect(subject.valid?(:visitors_set)).to be_truthy
    end

    it "fails if there is not at least one adult" do
      group_of_children
      subject.valid?
      expect(subject.valid?(:visitors_set)).to be_falsey
    end
  end

  it "requires a visit_id" do
    Visit.new do |visit|
      expect {
        visit.visit_id = SecureRandom.hex
      }.to change { visit.valid?(:visit_id) }.from(false).to(true)
    end
  end

  it "knows if a visitor is an adult or not" do
    expect(subject.adult?(adult_visitor)).to be_truthy
    expect(subject.adult?(child_visitor)).to be_falsey
  end

  describe 'same_visit?' do
    it 'is true if two different visits have the same visit_id' do
      a = subject
      b = subject.dup
      expect(a).not_to eq(b)
      expect(a).to be_same_visit(b)
    end

    it 'is false if two different visits have a different visit_id' do
      a = subject
      b = subject.dup
      b.visit_id = SecureRandom.hex
      expect(a).not_to be_same_visit(b)
    end
  end
end
