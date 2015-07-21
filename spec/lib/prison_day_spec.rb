require 'rails_helper'

RSpec.describe PrisonDay do
  let(:slots_for_everyday) do
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
      "unbookable"=> [],
      "slot_anomalies"=> {},
      "slots"=> slots_for_everyday
    }
  end

  describe '::BANK_HOLIDAYS' do
    it 'contains a duplicate array of the data found in the Rails configuration' do
      expect(described_class::BANK_HOLIDAYS).to match_array Rails.configuration.bank_holidays
    end
  end

  describe '#staff_working_day?' do
    context 'on a regular weekday' do
      Utilities::WEEKDAYS.each do |day_name, date|
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
      Utilities::WEEKEND_DAYS.each do |day_name, date|
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

  describe '#visiting_day?' do
    let(:prison_with_visits_except_thursday) do
      prison_from prison_data.replace(slots: slots_for_everyday.except("thu"))
    end

    let(:bank_holiday_friday) { Utilities::DAYS.fetch :friday }
    let(:stub_bank_holidays) do
      stub_const("#{described_class.name}::BANK_HOLIDAYS", [bank_holiday_friday])
    end

    let(:unbookable_monday) { Utilities::DAYS.fetch :monday }

    context 'on a day registered as available for visitation for a given prison' do
      specify do
        Utilities::DAYS.except(:thursday).each do |day_name, date|
          described_class.new(date, prison_with_visits_except_thursday).tap do |prison_day|
            expect(prison_day.visiting_day?).to be true
          end
        end
      end

      let(:monday_booking_slot) { slots_for_everyday.slice "mon" }

      context 'and has an anomalous booking slot' do
        let(:anomalous_monday) { Utilities::DAYS.fetch :monday }
        let(:prison_with_anomalous_date_on_visiting_day) do
          prison_from prison_data.
            merge(slot_anomalies: { anomalous_monday => ["1000-1200"] }).
            merge(slots: monday_booking_slot)
        end

        subject { described_class.new anomalous_monday, prison_with_anomalous_date_on_visiting_day }

        specify { expect(subject.visiting_day?).to be true }
      end

      context 'and is a public holiday' do
        before { stub_bank_holidays }
        subject { described_class.new bank_holiday_friday, prison_from(prison_data) }

        specify { expect(subject.visiting_day?).to be false }
      end

      context 'and is an unbookable date' do
        let(:prison_with_unbookable_date_on_visiting_date) do
          prison_from prison_data.
            merge(unbookable: [unbookable_monday]).
            merge(slots: monday_booking_slot)
        end

        subject { described_class.new unbookable_monday, prison_with_unbookable_date_on_visiting_date }

        specify { expect(subject.visiting_day?).to be false }

        context 'and has an anomalous booking slot' do
          let(:prison_with_unbookable_date_and_anomalous_slot_on_visiting_date) do
            prison_from prison_data.
              merge(unbookable: [unbookable_monday]).
              merge(slot_anomalies: { unbookable_monday => ["1000-1200"] }).
              merge(slots: monday_booking_slot)
          end

          subject do
            described_class.new unbookable_monday,
              prison_with_unbookable_date_and_anomalous_slot_on_visiting_date
          end

          specify { expect(subject.visiting_day?).to be false }
        end
      end
    end

    context 'on a day not registered for visitation for a given prison' do
      let(:non_available_visiting_day) { Utilities::DAYS.fetch :thursday }
      subject { described_class.new non_available_visiting_day, prison_with_visits_except_thursday }

      specify { expect(subject.visiting_day?).to be false }

      context 'and is a public holiday' do
        let(:prison_with_no_friday_visit) do
          prison_from prison_data.merge(slots: slots_for_everyday.except("fri"))
        end

        before { stub_bank_holidays }
        subject { described_class.new bank_holiday_friday, prison_with_no_friday_visit }

        specify { expect(subject.visiting_day?).to be false }
      end

      context 'and has an anomalous booking slot' do
        let(:anomalous_friday) { Utilities::DAYS.fetch :friday }
        let(:prison_with_no_friday_visit_but_anomalous_friday_slot) do
          prison_from prison_data.
            merge(slot_anomalies: { anomalous_friday => ["1000-1200"] }).
            merge(slots: slots_for_everyday.except("fri"))
        end

        subject do
          described_class.new anomalous_friday,
            prison_with_no_friday_visit_but_anomalous_friday_slot
        end

        specify { expect(subject.visiting_day?).to be true }
      end

      context 'and has an unbookable date' do
        let(:prison_with_unbookable_monday_and_no_monday_visit) do
          prison_from prison_data.
            merge(unbookable: [unbookable_monday]).
            merge(slots: slots_for_everyday.except("mon"))
        end

        subject do
          described_class.new unbookable_monday,
            prison_with_unbookable_monday_and_no_monday_visit
        end

        specify { expect(subject.visiting_day?).to be false }

        context 'and has an anomalous booking slot' do
          let(:prison_with_unbookable_monday_and_no_monday_visit_but_anomalous_monday_slot) do
            prison_from prison_data.
              merge(unbookable: [unbookable_monday]).
              merge(slot_anomalies: { unbookable_monday => ["1000-1200"] }).
              merge(slots: slots_for_everyday.except("mon"))
          end

          subject do
            described_class.new unbookable_monday,
              prison_with_unbookable_monday_and_no_monday_visit_but_anomalous_monday_slot
          end

          specify { expect(subject.visiting_day?).to be false }
        end
      end
    end
  end
end
