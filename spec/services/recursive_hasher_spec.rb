require 'rails_helper'

RSpec.describe RecursiveHasher do
  describe 'export' do
    subject { described_class.new.export(visit) }

    let(:visit) {
      Visit.new(
        visit_id: 'ABC123',
        prisoner: Prisoner.new(
          prison_name: 'Cardiff'
        ),
        visitors: [
          Visitor.new(
            email: 'user@example.com'
          )
        ]
      )
    }

    it { is_expected.to be_a(Hash) }

    it 'has boring attributes' do
      expect(subject.fetch(:visit_id)).to eq('ABC123')
    end

    context 'an attribute that is a model' do
      subject { super().fetch(:prisoner) }

      it { is_expected.to be_a(Hash) }

      it 'has boring attributes' do
        expect(subject.fetch(:prison_name)).to eq('Cardiff')
      end
    end

    context 'an attribute that is an array' do
      subject { super().fetch(:visitors) }

      it { is_expected.to be_a(Array) }

      context 'an element' do
        subject { super().fetch(0) }

        it { is_expected.to be_a(Hash) }

        it 'has boring attributes' do
          expect(subject.fetch(:email)).to eq('user@example.com')
        end
      end
    end
  end

  describe 'import' do
    subject { described_class.new.import(hash, Visit) }

    let(:hash) {
      {
        prisoner: {
          prison_name: "Cardiff"
        },
        visitors: [
          {
            email: "user@example.com"
          }
        ],
        slots: [],
        visit_id: "ABC123"
      }
    }

    it { is_expected.to be_a(Visit) }

    it 'has boring attributes' do
      expect(subject.visit_id).to eq('ABC123')
    end

    context 'an attribute that is a model' do
      subject { super().prisoner }

      it { is_expected.to be_a(Prisoner) }

      it 'has boring attributes' do
        expect(subject.prison_name).to eq('Cardiff')
      end
    end

    context 'an attribute that is an array' do
      subject { super().visitors }

      it { is_expected.to be_a(Array) }

      context 'an element' do
        subject { super().fetch(0) }

        it { is_expected.to be_a(Visitor) }

        it 'has boring attributes' do
          expect(subject.email).to eq('user@example.com')
        end
      end
    end
  end
end
