require 'rails_helper'

RSpec.describe Deferred::Visitor do
  it_behaves_like 'a visitor'

  context 'phone' do
    context 'for the first visitor' do
      before do
        subject.index = 0
      end

      it 'is invalid if missing' do
        subject.phone = nil
        subject.validate
        expect(subject.errors[:phone]).not_to be_empty
      end

      it 'is invalid if area code is missing' do
        subject.phone = '4960123'
        subject.validate
        expect(subject.errors[:phone]).
          to eq(['must include area code'])
      end

      it 'is valid if present and correct' do
        subject.phone = '01154960123'
        subject.validate
        expect(subject.errors[:phone]).to be_empty
      end
    end

    context 'for an additional visitor' do
      before do
        subject.index = 1
      end

      it 'is valid if absent' do
        subject.phone = nil
        subject.validate
        expect(subject.errors[:phone]).to be_empty
      end

      it 'is invalid if present' do
        subject.phone = '01154960123'
        subject.validate
        expect(subject.errors[:phone]).not_to be_empty
      end
    end
  end
end
