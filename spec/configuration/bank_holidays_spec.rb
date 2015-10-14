require 'rails_helper'

RSpec.describe 'Bank holidays' do
  describe 'bundled database' do
    subject do
      JSON.parse(File.read('config/bank-holidays.json'))['england-and-wales']['events']
    end

    it 'contains at least one bank holiday after today' do
      expect(
        subject.select { |day| Date.parse(day['date']) > Time.zone.today }
      ).not_to be_empty
    end

    describe 'a bank holiday object' do
      expected_keys = %w( bunting date notes title )

      it "contains the keys: #{expected_keys.to_sentence}" do
        subject.each do |hash|
          expect(hash.keys).to include(*expected_keys)
        end
      end
    end
  end
end
