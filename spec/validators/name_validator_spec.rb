require 'rails_helper'
require 'name_validator'

RSpec.describe NameValidator do
  subject do
    NameValidator.new(attributes: [:first_name])
  end

  let! :model do
    Visitor.new
  end

  it "doesn't allow for special characters in names" do
    expect {
      subject.validate_each(model, :first_name, '<Jeremy>')
    }.to change { model.errors.empty? }
  end

  it "enforces that names should be under 30 bytes in length" do
    expect {
      subject.validate_each(model, :first_name, 'A long string that is not a name')
    }.to change { model.errors.empty? }
  end

  it "allows legitimate names" do
    expect {
      subject.validate_each(model, :first_name, 'Manfred')
    }.not_to change { model.errors.empty? }
  end
end
