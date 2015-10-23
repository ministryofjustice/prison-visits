require 'rails_helper'

RSpec.describe DateHelper do
  describe '.format_date_of_birth' do
    it 'formats a date from a date' do
      expect(helper.format_date_of_birth(Date.parse('2014-07-24'))).to eq('24 July 2014')
    end
    it 'formats a date from a string' do
      expect(helper.format_date_of_birth('2014-07-24')).to eq('24 July 2014')
    end
  end

  describe '.format_date_of_visit' do
    it 'formats a day from a string' do
      expect(helper.format_date_of_visit('2014-07-24')).to eq('Thursday 24 July')
    end
    it 'formats a day from a date' do
      expect(helper.format_date_of_visit(Date.parse('2014-07-24'))).to eq('Thursday 24 July')
    end
  end

  describe '.format_time_12hr' do
    it 'formats a 24hr time string into a 12hr clock format' do
      expect(helper.format_time_12hr('0900')).to eq('9:00am')
      expect(helper.format_time_12hr('1200')).to eq('12:00pm')
      expect(helper.format_time_12hr('1545')).to eq('3:45pm')
    end
  end

  describe '.format_time_24hr' do
    it 'formats a 24hr time string with a separator between hours & minutes' do
      expect(helper.format_time_24hr('0900')).to eq('09:00')
      expect(helper.format_time_24hr('1200')).to eq('12:00')
      expect(helper.format_time_24hr('1545')).to eq('15:45')
    end
  end

  describe '.format_start_time' do
    it 'formats a start time from a 24hr time string' do
      expect(helper.format_start_time('0945-1145')).to eq('9:45am')
    end
  end

  describe '.format_slot_and_duration' do
    it 'displays a slot and duration' do
      expect(helper.format_slot_and_duration('0945-1145')).to eq('9:45am for 2 hrs')
      expect(helper.format_slot_and_duration('1430-1600')).to eq('2:30pm for 1 hr 30 mins')
    end
  end

  describe '.date_and_duration_of_slot' do
    let(:slot) { Slot.new(date: '2015-11-5', times: '1330-1430') }
    it 'displays the date and the time and duration of a slot' do
      expect(helper.date_and_duration_of_slot(slot)).to eq('Thursday 5 November 1:30pm for 1 hr')
    end
  end
end
