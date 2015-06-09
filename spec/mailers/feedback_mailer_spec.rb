require 'rails_helper'

RSpec.describe FeedbackMailer do
  let :subject do
    FeedbackMailer
  end

  let :feedback do
    Feedback.new(referrer: "ref")
  end

  it "responds with a referrer in a subject" do
    expect(subject.new_feedback(feedback).subject).to eq("PVB feedback: ref")
  end
end
