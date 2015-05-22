require 'spec_helper'

describe Rails.application.config.filter_parameters do
  it "filters out sensitive information" do
    expect(subject).to eq([:password, :first_name, :last_name, :number, :'date_of_birth(3i)', :'date_of_birth(2i)', :'date_of_birth(1i)', :email])
  end
end
