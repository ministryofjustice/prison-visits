require 'spec_helper'

describe VisitMetricsEntry do
  it "requires mandatory fields" do
    expect(subject).not_to be_valid

    subject.visit_id = "LOL"
    expect(subject).not_to be_valid

    subject.nomis_id = "RCI"
    expect(subject).not_to be_valid

    subject.requested_at = Time.now
    expect(subject).not_to be_valid

    subject.kind = 'instant'
    expect(subject).not_to be_valid

    subject.outcome = 'pending'
    expect(subject).to be_valid

    subject.kind = 'deferred'
    expect(subject).to be_valid
  end
end
