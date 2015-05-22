require 'spec_helper'

describe Time do
  it "sets the time zone to London" do
    expect(Time.zone.name).to eq('London')
  end
end
