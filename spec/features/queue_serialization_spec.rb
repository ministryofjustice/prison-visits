require 'rails_helper'

RSpec.feature 'Putting non-ActiveRecord objects on queues and taking them off again' do
  scenario 'round-tripping an object' do
    visit = Visit.new(
      slots: [Slot.new(date: '2015-01-01')],
      prisoner: Prisoner.new(first_name: 'Methuselah')
    )
    serialized = visit.to_global_id
    deserialized = GlobalID::Locator.locate(serialized)

    expect(deserialized).to be_kind_of(Visit)
    expect(deserialized.prisoner).to be_kind_of(Prisoner)
    expect(deserialized.prisoner.first_name).to eq('Methuselah')
    expect(deserialized.prisoner.last_name).to be_nil
    expect(deserialized.slots.fetch(0)).to be_kind_of(Slot)
    expect(deserialized.slots.fetch(0).date).to eq('2015-01-01')
  end
end
