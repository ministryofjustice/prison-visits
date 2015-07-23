require 'rails_helper'

RSpec.describe PrisonSchedule do
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

  describe '#confirmation_email_date' do
    context 'when the lead days are not broken up by a holiday or weekend' do
      let(:monday) { Utilities::DAYS.fetch :monday }
      let(:three_days_from_monday) { monday + 3.days }
      let(:prison_with_three_lead_days) { prison_from prison_data.merge(lead_days: 3) }

      subject { described_class.new prison_with_three_lead_days }

      it 'returns a date equal to the number of the prisons lead days from now' do
        Timecop.travel(monday) do
          expect(subject.confirmation_email_date).to eq three_days_from_monday
        end
      end
    end

    let(:thursday) { Utilities::DAYS.fetch :thursday }

    let(:prison_not_working_weekends_with_three_lead_days) do
      prison_from prison_data.merge(works_weekends: false, lead_days: 3)
    end

    context 'when the consecutive lead days are broken up by the weekend' do
      context 'when a prison doesnt work weekends' do
        let(:the_following_tuesday) { thursday + 5.days }

        subject { described_class.new prison_not_working_weekends_with_three_lead_days }

        it 'skips the weekend days' do
          Timecop.travel(thursday) do
            expect(subject.confirmation_email_date).to eq the_following_tuesday
          end
        end
      end

      context 'when a prison does work weekends' do
        let(:prison_working_weekends_with_three_lead_days) do
          prison_from prison_data.merge(works_weekends: true, lead_days: 3)
        end

        let(:sunday) { Utilities::DAYS.fetch :sunday }

        subject { described_class.new prison_working_weekends_with_three_lead_days }

        it 'returns a date on the weekend' do
          Timecop.travel(thursday) do
            expect(subject.confirmation_email_date).to eq sunday
          end
        end
      end
    end

    context 'when the consecutive lead days are broken up by a public holiday' do
      let(:friday) { Utilities::DAYS.fetch :friday }
      let(:the_following_wednesday) { thursday + 6.days }

      before do
        allow(Rails.configuration).to receive(:bank_holidays).and_return([friday])
      end

      subject { described_class.new prison_not_working_weekends_with_three_lead_days }

      it 'skips the public holiday' do
        Timecop.travel(thursday) do
          expect(subject.confirmation_email_date).to eq the_following_wednesday
        end
      end
    end

    context 'when the prison has zero lead days' do
      # Currently no prisons implement a 0 day turn around time
      # if they did we would also have to consider the working hours
      # of the prison.
      # If the user attempts to book for a prison with zero lead days outside
      # of working hours they would receive a booking receipt stating a
      # confirmation is expected on the same day.

      let(:prison_with_zero_lead_days) { prison_from prison_data.merge(lead_days: 0) }

      subject { described_class.new prison_with_zero_lead_days }

      it 'returns todays date' do
        Timecop.travel(thursday) do
          expect(subject.confirmation_email_date).to eq thursday
        end
      end
    end
  end

  describe '#available_visitation_dates' do
    #      June 2015
    # M  T  W  T  F  S  S
    # 1  2  3  4  5  6  7
    # 8  9  10 11 12 13 14
    # 15 16 17 18 19 20 21
    # 22 23 24 25 26 27 28
    # 29 30 1  2  3  4  5

    let(:one_off_anomalous_wednesday) { Date.parse 'Wed 10th June 2015' }
    let(:unbookable_monday) { Date.parse 'Mon 15th June 2015' }
    let(:unbookable_saturday) { Date.parse 'Sat 20th June 2015' }
    let(:public_holiday) { Date.parse 'Mon 22nd June 2015' }

    let(:prison_with_everyday_slots_except_wednesdays) do
      prison_from prison_data.
        merge(slots: slots_for_everyday.except('wed')).
        merge(slot_anomalies: { one_off_anomalous_wednesday => "1000-1200" }).
        merge(unbookable: [unbookable_monday, unbookable_saturday]).
        merge(lead_days: 3).
        merge(booking_window: 28)
    end

    let(:monday_june_01_2015) { Date.parse 'Mon 1st June 2015' }

    let(:expected_available_date_range) { Date.parse('Fri 5th June 2015')..Date.parse('Mon 29th June 2015') }

    let(:expected_dates) do
      expected_available_date_range.to_a.delete_if(&:wednesday?).append(one_off_anomalous_wednesday) -
        [public_holiday, unbookable_monday, unbookable_saturday]
    end

    before do
      allow(Rails.configuration).to receive(:bank_holidays).and_return([public_holiday])
    end

    around { |example| Timecop.travel(monday_june_01_2015) { example.run } }

    subject { described_class.new prison_with_everyday_slots_except_wednesdays }

    it 'returns a list of days the prison can accept visitors excluding unbookable dates & public holidays' do
      expect(subject.available_visitation_dates).to match_array expected_dates
    end

    it 'ignores days that are not specified as slots unless a date is anomalous' do
      wednesday_slots = subject.available_visitation_dates.select(&:wednesday?)
      expect(wednesday_slots).to match_array [one_off_anomalous_wednesday]
    end

    describe 'the range of dates covered' do
      let(:the_day_after_the_conformation_email) { subject.confirmation_email_date.next_day }
      let(:booking_window_days) { 28.days }

      it 'starts from the day after the confirmation email' do
        expect(subject.available_visitation_dates.first).to eq the_day_after_the_conformation_email
      end

      it 'doesnt offer dates beyond the number of booking window days from today' do
        expect(subject.available_visitation_dates.last).to eq booking_window_days.from_now.to_date
      end
    end
  end
end
