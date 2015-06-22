require 'rails_helper'

RSpec.describe Schedule do
  subject do
    bank_holidays = [Date.new(2014, 8, 25), Date.new(2015, 4, 3), Date.new(2015, 4, 6)]
    Schedule.new(prison, bank_holidays)
  end

  let :start_date do
    Date.new(2014, 12, 6)
  end

  context "always" do
    let :prison do
      Rails.configuration.prison_data['Durham']
    end

    it "returns days within 28 days, excluding the lead days" do
      subject.dates(start_date).each do |date|
        expect(date).to be >= start_date + 3
        expect(date).to be <= start_date + 28
      end
    end

    it "doesn't offer unbookable dates" do
      subject.dates(start_date).each do |date|
        expect(date).not_to eq(Date.new(2014, 12, 25))
        expect(date).not_to eq(Date.new(2014, 12, 26))
      end
    end

    it "offers visits every day of the week" do
      subject.dates(start_date).collect do |date|
        date.wday
      end.sort == 7.times.to_a
    end

    it "assumes bookings aren't processed on weekends" do
      #     August 2014
      # Su Mo Tu We Th Fr Sa
      #                 1  2
      #  3  4  5  6  7  8  9
      # 10 11 12 13 14 15 16
      # 17 18 19 20 21 22 23
      # 24<25>26 27 28 29 30
      # 31

      week_start = monday = Date.new(2014, 8, 18)
      first_bookable_visits = {
        :monday => week_start.next_day(Date::DAYS_INTO_WEEK[:friday]),
        :tuesday => week_start.next_day(Date::DAYS_INTO_WEEK[:saturday]),
        :wednesday => week_start.next_week(:wednesday),
        :thursday => week_start.next_week(:thursday),
        :friday => week_start.next_week(:friday),
        :saturday => week_start.next_week(:friday),
        :sunday => week_start.next_week(:friday),
      }

      first_bookable_visits.each do |request_day, visit_on|
        request_date = week_start.next_day(Date::DAYS_INTO_WEEK[request_day])
        expect(subject.dates(request_date).first).to eq(visit_on)
      end
    end

    it "assumes bookings are not processed on bank holidays" do
      #      April 2015
      # Su Mo Tu We Th Fr Sa
      #           1  2 <3> 4
      #  5 <6> 7  8  9 10 11
      # 12 13 14 15 16 17 18
      # 19 20 21 22 23 24 25
      # 26 27 28 29 30

      start_date = Date.new(2015, 4, 2)
      expect(subject.dates(start_date).first).to eq(start_date.next_week(:friday))
    end
  end

  context "prison with one day without visits" do
    let :prison do
      Rails.configuration.prison_data['Rochester']
    end

    it "rejects days without slots" do
      subject.dates(start_date).each do |date|
        expect(date.friday?).to be false
      end
    end
  end

  context "prison works on weekends" do
    let :prison do
      Rails.configuration.prison_data['Lewes']
    end

    it "does indeed work on weekends" do
      (Date.new(2015, 6, 18)..Date.new(2015, 6, 24)).each do |start_date|
        expect(subject.dates(start_date).first).to eq(start_date + 4)
      end
    end
  end

  context "prison with anomalies" do
    let :prison do
      Rails.configuration.prison_data['Warren Hill'].dup
    end

    it "applies anomalous slots" do
      anomalous_date = (Date.new(2014, 1, 4)..Date.new(2014, 2, 1)).find do |date|
        date.wednesday?
      end
      prison[:slot_anomalies] = {anomalous_date => ['0945-1300']}
      expect(subject.dates(Date.new(2014, 1, 1)).to_a).to include anomalous_date
    end
  end

  context "prison with custom lead days" do
    #    December 2014
    # Su Mo Tu We Th Fr Sa
    #     1  2  3  4  5  6
    #  7  8  9 10 11 12 13
    # 14 15 16 17 18 19 20
    # 21 22 23 24 25 26 27
    # 28 29 30 31

    let :prison do
      Rails.configuration.prison_data['Durham'].dup
    end

    it "allows earlier bookings" do
      prison[:lead_days] = 0

      expect(subject.dates(start_date).first).to eq(start_date + 2)
    end

    context "which works on weekends" do
      let :prison do
        Rails.configuration.prison_data['Lewes'].dup
      end

      it "allows earlier bookings" do
        prison[:lead_days] = 0

        expect(subject.dates(start_date).first).to eq(start_date + 1)
      end
    end
  end

  context "custom lead days equal to zero (next-day visits) when the prison works on weekends" do
    let :prison do
      Rails.configuration.prison_data['Highpoint North'].dup
    end

    it "allows a next-day booking but not on the weekend" do
      prison[:lead_days] = 0

      #    December 2014
      # Su Mo Tu We Th Fr Sa
      #     1  2  3  4  5  6
      #  7  8  9 10 11 12 13
      # 14 15 16 17 18 19 20
      # 21 22 23 24 25 26 27
      # 28 29 30 31

      date_range = (Date.new(2014, 12, 1)..Date.new(2014, 12, 28))

      week_start = Date.new(2014, 12, 1)
      first_bookable_visits = {
        :monday => week_start.next_day(Date::DAYS_INTO_WEEK[:tuesday]),
        :tuesday => week_start.next_day(Date::DAYS_INTO_WEEK[:wednesday]),
        :wednesday => week_start.next_day(Date::DAYS_INTO_WEEK[:thursday]),
        :thursday => week_start.next_day(Date::DAYS_INTO_WEEK[:friday]),
        :friday => week_start.next_week(:monday),
        :saturday => week_start.next_week(:monday),
        :sunday => week_start.next_week(:monday),
      }

      first_bookable_visits.each do |request_day, visit_on|
        request_date = week_start.next_day(Date::DAYS_INTO_WEEK[request_day])
        expect(subject.except_lead_days(request_date, date_range).first).to eq(visit_on)
      end

      expect(subject.dates(start_date = Date.new(2014, 12, 4)).first).to eq(start_date + 1)
    end
  end

  context "prison without unbookable dates" do
    let :prison do
      Rails.configuration.prison_data['Oakwood'].dup
    end

    it "should return a list of dates" do
      expect(subject.dates(start_date = Date.new(2014, 12, 4)).first).to be_nil
    end
  end

  context "prison that permits bookings only two weeks in advance" do
    let :prison do
      Rails.configuration.prison_data['Cardiff'].dup
    end

    it "returns days within 14 days, excluding the lead days" do
      subject.dates(start_date).each do |date|
        expect(date).to be >= start_date + 3
        expect(date).to be <= start_date + 14
      end
    end
  end
end
