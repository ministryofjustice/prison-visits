require 'spec_helper'

describe 'Bank holidays' do
  describe 'bundled database' do
    subject do
      JSON.parse(File.read('config/bank-holidays.json'))['england-and-wales']['events']
    end

    it 'contains at least one bank holiday after today' do
      expect(subject.map do |entry|
        Date.parse(entry['date'])
      end.find do |date|
        date > Date.today
      end).not_to be_nil
    end
  end

  describe 'remote data source' do
    subject do
      JSON.parse(Curl::Easy.perform('https://www.gov.uk/bank-holidays.json').body_str)
    end

    it 'contains a list of holidays' do
      first_entry = subject['england-and-wales']['events'].first
      first_entry.keys.to_set > Set['bunting', 'date', 'notes', 'title']
    end
  end
end
