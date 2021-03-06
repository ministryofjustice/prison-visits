require 'rails_helper'
require 'shared_examples_prison_slots_and_data'

RSpec.describe Prison, type: :model do
  include_examples "prison slots and data"

  let!(:complete_prison) {
    described_class.create(
      basic_attributes.merge(advanced_attributes)
    )
  }

  let!(:basic_prison) { described_class.create(basic_attributes) }
  let!(:disabled_prison) {
    described_class.create(basic_attributes.merge('enabled' => false))
  }

  context 'class methods' do
    describe '.find' do
      context 'by name' do
        context 'when a prison exists' do
          subject { described_class.find('Cardiff') }

          it 'returns the correct prison' do
            expect(subject.name).to eq('Cardiff')
            expect(subject.nomis_id).to eq('CFI')
          end
        end

        context 'when a prison does not exist' do
          it 'returns nil by default' do
            expect(described_class.find('Not A Prison')).to be_nil
          end
        end

        context 'by nomis_is' do
          context 'when a prison exists' do
            subject { described_class.find_by_nomis_id('CFI') }

            it 'returns the correct prison' do
              expect(subject.name).to eq('Cardiff')
              expect(subject.nomis_id).to eq('CFI')
            end
          end

          context 'when a prison does not exist' do
            it 'returns nil by default' do
              expect(described_class.find('Not a valid ID')).to be_nil
            end
          end
        end
      end

      context 'collections' do
        let(:enabled)  { object_double(described_class.new, nomis_id: 'ENA', name: 'Enabled', enabled: true) }
        let(:disabled) { object_double(described_class.new, nomis_id: 'DIS', name: 'Disabled', enabled: false) }
        let(:no_nomis) { object_double(described_class.new, nomis_id: nil, name: 'No Nomis', enabled: false) }

        let(:prisons) {[enabled, disabled, no_nomis]}
        before do; allow(Rails.configuration).to receive(:prisons).and_return(prisons) end

        describe '.enabled' do
          it 'returns only enabled prisons' do
            expect(described_class.enabled).to match_array([enabled])
          end

          it 'does not return disabled prisons' do
            expect(described_class.enabled).not_to include(disabled, no_nomis)
          end
        end

        describe '.all' do
          it 'returns all prisons' do
            expect(described_class.all).to match_array(prisons)
          end
        end

        describe '.names' do
          it 'returns all names' do
            expect(described_class.names).to match_array(['Enabled', 'Disabled', 'No Nomis'])
          end
        end

        describe '.nomis_ids' do
          it 'returns nomis ids for all prisons with a nomis id' do
            expect(described_class.nomis_ids).to match_array(['DIS', 'ENA'])
          end
        end

        describe '.enabled_nomis_ids' do
          it 'returns nomis ids for all enabled prisons with a nomis id' do
            expect(described_class.enabled_nomis_ids).to match_array(['ENA'])
          end
        end
      end
    end

    context 'instance methods' do
      subject { complete_prison }

      describe '#name' do
        it { expect(subject.name).to eq 'Advanced Prison' }
      end

      describe '#adult_age' do
        it { expect(subject.adult_age).to eq 18 }
      end

      describe '#enabled?' do
        it { expect(subject.enabled?).to be_truthy }
      end

      describe '#estate' do
        it { expect(subject.estate).to eq 'Advanced' }
      end

      describe '#unbookable_dates' do
        context 'when a prison has unbookable dates' do
          let(:expected_dates) { Set.new [Date.new(2015, 7, 29), Date.new(2015, 12, 25)] }

          it 'returns a set containing the dates' do
            expect(subject.unbookable_dates).to eq expected_dates
          end
        end

        context 'when a prison does not have unbookable dates' do
          subject { basic_prison }
          it 'returns an empty set' do
            expect(subject.unbookable_dates).to be_empty
            expect(subject.unbookable_dates).to be_kind_of Set
          end
        end
      end

      describe '#visiting_slots' do
        it 'returns the prisons slots as a hash' do
          expect(subject.visiting_slots).to eq mock_slots_data
        end
      end

      describe '#visiting_slot_days' do
        let(:expected_slot_days_for_everyday_visits) { %w[mon tue wed thu fri sat sun] }
        let(:weekend_slots_data) {  { "sat" => ["0930-1130"], "sun" => ["1400-1600"] } }
        let(:expected_slot_days_for_weekend_only_visits) { %w[sat sun] }

        context 'for a prison with everyday visits' do
          it 'returns the abbreviated day names of available visiting days for the prison' do
            expect(subject.visiting_slot_days).
              to eq expected_slot_days_for_everyday_visits
          end
        end

        context 'for a prison with weekend only visits' do
          before do; subject.slots = weekend_slots_data end
          it 'returns the abbreviated day names of available visiting days for the prison' do
            expect(subject.visiting_slot_days).
              to eq expected_slot_days_for_weekend_only_visits
          end
        end
      end

      describe '#anomalous_dates' do
        context 'when a prison has days for visitation that are different from the regular slots' do
          subject { complete_prison }
          let(:expected_anomalous_dates) { Set.new [Date.new(2015, 8, 14)] }

          it 'returns the day' do
            expect(subject.anomalous_dates).to eq expected_anomalous_dates
          end
        end

        context 'when a prison has no anomalous slots' do
          before do; subject.slot_anomalies = nil end

          it 'returns an empty set' do
            subject.anomalous_dates.tap do |set|
              expect(set).to be_empty
              expect(set).to be_kind_of Set
            end
          end
        end
      end

      describe '#days_lead_time' do
        context 'when a prison has a lead time explicitly set' do
          it 'returns the value set by the prison config' do
            expect(subject.days_lead_time).to eq 4
          end
        end

        context 'when no lead time has been set' do
          subject { basic_prison }
          it 'returns the default value' do
            expect(subject.days_lead_time).to eq 3
          end
        end
      end

      describe '#booking_window' do
        context 'when a prison has a booking window explicitly set' do
          it 'returns the value set by the prison config' do
            expect(subject.booking_window).to eq 14
          end
        end
        context 'when no booking window has been set' do
          subject { basic_prison }

          it 'returns the default value' do
            expect(subject.booking_window).to eq 28
          end
        end
      end

      describe '#works_weekends?' do
        context 'when a prison has a works weekends boolean flag set' do
          it 'returns that boolean' do
            expect(subject.works_weekends?).to be true
          end
        end
        context 'when no works weekends boolean flag has been set' do
          subject { basic_prison }
          specify { expect(subject.works_weekends?).to be false }
        end
      end

      describe '#works_everyday?' do
        it 'acts as an alias for .works_weekends?' do
          expect(subject.method(:works_everyday?)).to eq subject.method(:works_weekends?)
        end
      end
    end
  end
end
