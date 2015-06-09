require 'rails_helper'

RSpec.describe MetricsHelper do
  it "displays zero" do
    expect(helper.display_interval(0)).to eq("0s")
  end

  it "displays a long time" do
    expect(helper.display_interval(229418)).to eq("2d15h43m38s")
  end

  it "passes through nil" do
    expect(helper.display_interval(nil)).to be_nil
  end

  it "displays percentages" do
    expect(helper.display_percent(1.0/3)).to eq("33.3")
    expect(helper.display_percent(0.1)).to eq("10.0")
    expect(helper.display_percent(0.0)).to eq("0.0")
  end
end
