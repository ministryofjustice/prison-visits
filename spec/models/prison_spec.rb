require 'rails_helper'

RSpec.describe Prison, type: :model do
  let(:mock_slots_data) do
    {
      "mon"=>["1400-1600"],
      "tue"=>["1400-1600"],
      "wed"=>["1400-1600"],
      "thu"=>["1400-1600"],
      "fri"=>["1400-1600"],
      "sat"=>["0930-1130", "1400-1600"],
      "sun"=>["1400-1600"]
    }
  end

  let(:mock_prison_data) do
    {
      "nomis_id"=>"RCI",
      "canned_responses"=>true,
      "enabled"=>true,
      "phone"=>"01634 803100",
      "email"=>"pvb.rochester@maildrop.dsd.io",
      "instant_booking"=>false,
      "address"=>["1 Fort Road", "Rochester", "Kent", "ME1 3QS"],
      "lead_days"=>4,
      "booking_window"=>14,
      "works_weekends"=>true,
      "unbookable"=>[Date.new(2015, 7, 29), Date.new(2015, 12, 25)],
      "slot_anomalies"=>{Date.new(2015, 8, 14)=>["0700-0900"]},
      "slots"=> mock_slots_data
    }
  end

  describe '.find' do
    context 'when a prison exists' do
      it 'returns a prison instance' do
        expect(Rails.configuration.prison_data).to receive(:[]).
          with('Example Prison') { mock_prison_data }

        prison = described_class.find 'Example Prison'
        expect(prison).to be_kind_of described_class
      end
    end
    context 'when a prison does not exist' do
      it 'raises a PrisonNotFound error' do
        allow(Rails.configuration.prison_data).to receive(:[]) { nil }

        expect { described_class.find('nothing') }.
          to raise_error(described_class::PrisonNotFound)
      end
    end
  end

  def constructor_for(prison_data)
    described_class.new 'Example Prison', prison_data
  end

  subject { constructor_for mock_prison_data }

  describe '#name' do
    it 'returns the name of the prison' do
      expect(subject.name).to eq 'Example Prison'
    end
  end

  describe '#unbookable_dates' do
    context 'when a prison has unbookable dates' do
      let(:expected_dates) { Set.new [Date.new(2015, 7, 29), Date.new(2015, 12, 25)] }

      it 'returns a set containing the dates' do
        expect(subject.unbookable_dates).to eq expected_dates
      end
    end
    context 'when a prison does not have unbookable dates' do
      subject { constructor_for mock_prison_data.except 'unbookable' }

      it 'returns an empty set' do
        subject.unbookable_dates.tap do |set|
          expect(set).to be_empty
          expect(set).to be_kind_of Set
        end
      end
    end
  end

  describe '#visiting_slots' do
    it 'returns the prisons slots as a hash' do
      expect(subject.visiting_slots).to eq mock_slots_data
    end
  end

  describe '#visiting_slot_days' do
    let(:prison_with_everyday_visits) { subject }
    let(:expected_slot_days_for_everyday_visits) { %w<mon tue wed thu fri sat sun> }

    let(:weekend_slots_data) {  { "sat"=>["0930-1130"], "sun"=>["1400-1600"] } }
    let(:expected_slot_days_for_weekend_only_visits) { %w<sat sun> }
    let(:prison_with_weekend_only_visists) {
      constructor_for mock_prison_data.replace('slots' => weekend_slots_data)
    }

    it 'returns the abbreviated day names of available visiting days for the prison' do
      expect(prison_with_everyday_visits.visiting_slot_days).
        to eq expected_slot_days_for_everyday_visits
      expect(prison_with_weekend_only_visists.visiting_slot_days).
        to eq expected_slot_days_for_weekend_only_visits
    end
  end

  describe '#anomalous_dates' do
    context 'when a prison has days for visitation that are different from the regular slots' do
      let(:expected_anomalous_dates) { Set.new [Date.new(2015, 8, 14)] }
      it 'returns the day' do
        expect(subject.anomalous_dates).to eq expected_anomalous_dates
      end
    end
    context 'when a prison has no anomalous slots' do
      subject { constructor_for mock_prison_data.except 'slot_anomalies' }

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
      subject { constructor_for mock_prison_data.except 'lead_days' }

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
      subject { constructor_for mock_prison_data.except 'booking_window' }

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
      subject { constructor_for mock_prison_data.except 'works_weekends' }

      specify { expect(subject.works_weekends?).to be false }
    end
  end

  describe '#works_everyday?' do
    it 'acts as an alias for .works_weekends?' do
      expect(subject.method(:works_everyday?)).to eq subject.method(:works_weekends?)
    end
  end
end
