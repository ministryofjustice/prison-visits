require 'rails_helper'

RSpec.describe Schedule do
  subject do
    Schedule.new(prison, [Date.new(2014, 8, 25), Date.new(2015, 4, 3), Date.new(2015, 4, 6)])
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

    it "rejects unbookable dates" do
      subject.dates(start_date).each do |date|
        expect(date).not_to eq(Date.parse('2014-12-25'))
        expect(date).not_to eq(Date.parse('2014-12-26'))
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

      start_date = Date.new(2014, 8, 18) # Monday
      expect(subject.dates(start_date).first).to eq(start_date + 4) # Friday

      start_date = Date.new(2014, 8, 19) # Tuesday
      expect(subject.dates(start_date).first).to eq(start_date + 4) # Saturday

      start_date = Date.new(2014, 8, 20) # Wednesday
      expect(subject.dates(start_date).first).to eq(start_date + 7) # Wednesday

      start_date = Date.new(2014, 8, 21) # Thursday
      expect(subject.dates(start_date).first).to eq(start_date + 7) # Thursday

      start_date = Date.new(2014, 8, 22) # Friday
      expect(subject.dates(start_date).first).to eq(start_date + 7) # Friday

      start_date = Date.new(2014, 8, 23) # Saturday
      expect(subject.dates(start_date).first).to eq(start_date + 6) # Friday

      start_date = Date.new(2014, 8, 24) # Sunday
      expect(subject.dates(start_date).first).to eq(start_date + 5) # Friday
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
      expect(subject.dates(start_date).first).to eq(start_date + 8)
    end
  end

  context "prison with one day without visits" do
    let :prison do
      Rails.configuration.prison_data['Rochester']
    end

    it "rejects days without slots" do
      subject.dates(start_date).each do |date|
        expect(date.wday).not_to eq(5)
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
        date.wday == 3
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

      # Monday
      start_date = Date.new(2014, 12, 1)
      expect(subject.except_lead_days(start_date, date_range).first).to eq(start_date + 1)

      # Tuesday
      start_date = Date.new(2014, 12, 2)
      expect(subject.except_lead_days(start_date, date_range).first).to eq(start_date + 1)

      # Wednesday
      start_date = Date.new(2014, 12, 3)
      expect(subject.except_lead_days(start_date, date_range).first).to eq(start_date + 1)

      # Thursday
      start_date = Date.new(2014, 12, 4)
      expect(subject.except_lead_days(start_date, date_range).first).to eq(start_date + 1)

      # Friday
      start_date = Date.new(2014, 12, 5)
      expect(subject.except_lead_days(start_date, date_range).first).to eq(start_date + 3)

      # Saturday
      start_date = Date.new(2014, 12, 6)
      expect(subject.except_lead_days(start_date, date_range).first).to eq(start_date + 2)

      # Sunday
      start_date = Date.new(2014, 12, 7)
      expect(subject.except_lead_days(start_date, date_range).first).to eq(start_date + 1)

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
