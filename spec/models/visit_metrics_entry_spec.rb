require 'spec_helper'

describe VisitMetricsEntry do
  it "requires mandatory fields" do
    subject.should_not be_valid

    subject.visit_id = "LOL"
    subject.should_not be_valid

    subject.nomis_id = "RCI"
    subject.should_not be_valid

    subject.requested_at = Time.now
    subject.should_not be_valid

    subject.kind = 'instant'
    subject.should be_valid

    subject.kind = 'deferred'
    subject.should be_valid
  end
end
