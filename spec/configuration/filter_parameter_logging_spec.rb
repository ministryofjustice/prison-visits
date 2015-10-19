require 'rails_helper'

RSpec.describe Rails.application.config.filter_parameters do
  it "filters out sensitive information" do
    expect(subject).to eq(
      [:password, :first_name, :last_name, :number, :date_of_birth, :email]
    )
  end
end
