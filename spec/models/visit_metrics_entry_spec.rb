require 'rails_helper'

RSpec.describe VisitMetricsEntry do
  it "requires mandatory fields" do
    expect(subject).not_to be_valid

    subject.visit_id = "LOL"
    expect(subject).not_to be_valid

    subject.nomis_id = "RCI"
    expect(subject).not_to be_valid

    subject.requested_at = Time.now
    expect(subject).not_to be_valid

    subject.outcome = 'pending'
    subject.kind = 'deferred'
    expect(subject).to be_valid
  end
end
