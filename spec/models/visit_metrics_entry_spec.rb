require 'rails_helper'

RSpec.describe VisitMetricsEntry do
  subject{ described_class.new(nomis_id: 'RCI', requested_at: Time.now, visit_id: 1234) }

  it { expect(subject).to be_valid }

  describe '#outcome' do
    let(:valid_outcomes) { %w[pending confirmed rejected request_cancelled visit_cancelled] }

    it 'starts in pending' do
      expect(subject.outcome).to eq 'pending'
    end

    it 'accepts all valid outcomes' do
      valid_outcomes.each do |outcome|
        subject.outcome = outcome
        expect(subject).to be_valid
      end
    end

    it 'is not vaild if outcome is invalid' do
      subject.outcome = 'lost'
      expect(subject).not_to be_valid
    end
  end

  describe '#nomis_id' do
    before { subject.nomis_id = nil }
    it { expect(subject).not_to be_valid }
  end

  describe '#visit_id' do
    before { subject.visit_id = nil }
    it { expect(subject).not_to be_valid }
  end

  describe '#requested_at' do
    before { subject.requested_at = nil }
    it { expect(subject).not_to be_valid }
  end
end
