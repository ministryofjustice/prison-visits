require "spec_helper"

describe FeedbackMailer do
  let :subject do
    FeedbackMailer
  end

  let :feedback do
    Feedback.new(referrer: "ref")
  end

  it "responds with a referrer in a subject" do
    subject.new_feedback(feedback).subject.should == "PVB feedback: ref"
  end
end
