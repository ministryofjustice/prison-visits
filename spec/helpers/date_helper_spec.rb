require 'rails_helper'

RSpec.describe DateHelper do
  it "formats a date from a string" do
    expect(helper.format_date_of_birth('2014-07-24')).to eq("24 July 2014")
  end

  it "formats a date from a date" do
    expect(helper.format_date_of_birth(Date.parse('2014-07-24'))).to eq("24 July 2014")
  end

  it "formats a day from a string" do
    expect(helper.format_date_of_visit('2014-07-24')).to eq("Thursday 24 July")
  end

  it "formats a day from a date" do
    expect(helper.format_date_of_visit(Date.parse('2014-07-24'))).to eq("Thursday 24 July")
  end
end
