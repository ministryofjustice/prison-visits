require 'spec_helper'

describe Schedule do
  subject do
    Schedule.new(prison)
  end

  let :start_date do
    Date.new(2014, 12, 6)
  end

  context "always" do
    let :prison do
      Rails.configuration.prison_data['Durham']
    end
    
    it "returns days within 28 days, excluding the lead days" do
      subject.dates(start_date, 28).each do |date|
        date.should >= start_date + 3
        date.should <= start_date + 28
      end
    end

    it "rejects unbookable dates" do
      subject.dates(start_date, 28).each do |date|
        date.should_not == Date.parse('2014-12-25')
        date.should_not == Date.parse('2014-12-26')
      end
    end

    it "offers visits every day of the week" do
      subject.dates(start_date, 10).collect do |date|
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
      # 24 25 26 27 28 29 30
      # 31

      start_date = Date.new(2014, 8, 18) # Monday
      subject.dates(start_date, 14).first.should == start_date + 4 # Friday

      start_date = Date.new(2014, 8, 19) # Tuesday
      subject.dates(start_date, 14).first.should == start_date + 4 # Saturday

      start_date = Date.new(2014, 8, 20) # Wednesday
      subject.dates(start_date, 14).first.should == start_date + 6 # Tuesday

      start_date = Date.new(2014, 8, 21) # Thursday
      subject.dates(start_date, 14).first.should == start_date + 6 # Wednesday

      start_date = Date.new(2014, 8, 22) # Friday
      subject.dates(start_date, 14).first.should == start_date + 6 # Thursday

      start_date = Date.new(2014, 8, 23) # Saturday
      subject.dates(start_date, 14).first.should == start_date + 5 # Thursday

      start_date = Date.new(2014, 8, 24) # Sunday
      subject.dates(start_date, 14).first.should == start_date + 4 # Thursday
    end
  end

  context "prison with one day without visits" do
    let :prison do
      Rails.configuration.prison_data['Rochester']
    end

    it "rejects days without slots" do
      subject.dates(start_date, 28).each do |date|
        date.wday.should_not == 5
      end
    end
  end

  context "prison works on weekends" do
    let :prison do
      Rails.configuration.prison_data['Lewes']
    end

    it "does indeed work on weekends" do
      (Date.new(2014, 8, 18)..Date.new(2014, 8, 24)).each do |start_date|
        subject.dates(start_date, 14).first.should == start_date + 4
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
      subject.dates(Date.new(2014, 1, 1), 60).to_a.should include anomalous_date
    end
  end
end
