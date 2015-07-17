require 'rails_helper'

RSpec.describe PrisonDay do
  DAYS = {
    monday:     Date.parse('Mon 13 July 2015'),
    tuesday:    Date.parse('Tue 14 July 2015'),
    wednesday:  Date.parse('Wed 15 July 2015'),
    thursday:   Date.parse('Thu 16 July 2015'),
    friday:     Date.parse('Fri 17 July 2015'),
    saturday:   Date.parse('Sat 18 July 2015'),
    sunday:     Date.parse('Sun 19 July 2015')
  }.freeze

  WEEKDAYS = DAYS.except(:saturday, :sunday).freeze
  WEEKEND_DAYS = DAYS.slice(:saturday, :sunday).freeze

  let(:unbookable_dates) { Array.new }
  let(:slot_anomalies)   { Hash.new }
  let(:slot_data) do
    {
      "mon"=>["1400-1600"],
      "tue"=>["1400-1600"],
      "wed"=>["1400-1600"],
      "thu"=>["1400-1600"],
      "fri"=>["1400-1600"],
      "sat"=>["0930-1130"],
      "sun"=>["1400-1600"]
    }
  end

  let(:prison_data) do
    {
      "nomis_id"=>"RCI",
      "canned_responses"=>true,
      "enabled"=>true,
      "phone"=>"01634 803100",
      "email"=>"pvb.rochester@maildrop.dsd.io",
      "instant_booking"=>false,
      "address"=>["1 Fort Road", "Rochester", "Kent", "ME1 3QS"],
      "unbookable"=> unbookable_dates,
      "slot_anomalies"=> slot_anomalies,
      "slots"=> slot_data
    }
  end

  def prison_from(prison_data)
    Prison.new 'Example Prison', prison_data
  end

  describe '::BANK_HOLIDAYS' do
    it 'contains a duplicate array of the data found in the Rails configuration' do
      expect(described_class::BANK_HOLIDAYS).to match_array Rails.configuration.bank_holidays
    end
  end

  describe '.staff_working_day?' do
    context 'on a regular weekday' do
      WEEKDAYS.each do |day_name, date|
        subject { described_class.new(date, prison_from(prison_data)) }
        context "like a #{day_name}" do
          specify { expect(subject.staff_working_day?).to be true }
        end
      end
    end

    context 'on a public holiday' do
      let(:bank_holidays) { [Date.new(2015, 8, 31)] }
      before { stub_const("#{described_class.name}::BANK_HOLIDAYS", bank_holidays) }
      subject { described_class.new(bank_holidays.first, prison_from(prison_data)) }

      specify { expect(subject.staff_working_day?).to be false }
    end

    context 'on a weekend day' do
      WEEKEND_DAYS.each do |day_name, date|
        context "like a #{day_name}" do
          context 'for a prison that works weekends' do
            subject { described_class.new(date, prison_from(prison_data.merge works_weekends: true)) }
            specify { expect(subject.staff_working_day?).to be true }
          end

          context 'for a prison that does not work weekends' do
            subject { described_class.new(date, prison_from(prison_data.merge works_weekends: false)) }
            specify { expect(subject.staff_working_day?).to be false }
          end
        end
      end
    end
  end
end
