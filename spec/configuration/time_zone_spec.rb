require 'rails_helper'

RSpec.describe Time do
  it "sets the time zone to London" do
    expect(Time.zone.name).to eq('London')
  end
end
