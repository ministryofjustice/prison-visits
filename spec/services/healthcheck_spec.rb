require 'rails_helper'

RSpec.describe Healthcheck do
  subject { described_class.new }

  let(:mailers_queue) { [] }
  let(:zendesk_queue) { [] }

  before do
    allow(Sidekiq::Queue).
      to receive(:new).
      with('mailers').
      and_return mailers_queue
    allow(Sidekiq::Queue).
      to receive(:new).
      with('zendesk').
      and_return zendesk_queue
  end

  context 'when everything is OK' do
    context 'with empty queues' do
      it { is_expected.to be_ok }

      it 'reports all checks as true' do
        expect(subject.checks).to eq(
          database: true,
          mailers: true,
          zendesk: true
        )
      end

      it 'reports the queue status' do
        expect(subject.queues).to eq(
          mailers: { oldest: nil, count: 0 },
          zendesk: { oldest: nil, count: 0 }
        )
      end
    end

    context 'with only fresh queue items' do
      let(:mq_created_at) { 9.minutes.ago }
      let(:zq_created_at) { 8.minutes.ago }
      let(:mailers_queue) {
        [double(Sidekiq::Job, created_at: mq_created_at)]
      }
      let(:zendesk_queue) {
        [double(Sidekiq::Job, created_at: zq_created_at)]
      }

      it { is_expected.to be_ok }

      it 'reports all checks as true' do
        expect(subject.checks).to eq(
          database: true,
          mailers: true,
          zendesk: true
        )
      end

      it 'reports the queue status' do
        expect(subject.queues).to eq(
          mailers: { oldest: mq_created_at, count: 1 },
          zendesk: { oldest: zq_created_at, count: 1 }
        )
      end
    end
  end

  context 'when there is a problem' do
    context 'with stale mailers queue items' do
      let(:mq_created_at) { 11.minutes.ago }
      let(:mailers_queue) {
        [double(Sidekiq::Job, created_at: mq_created_at)]
      }

      it { is_expected.not_to be_ok }

      it 'reports the mailers check as false' do
        expect(subject.checks).to include(mailers: false)
      end

      it 'reports the mailers queue status' do
        expect(subject.queues).to include(
          mailers: { oldest: mq_created_at, count: 1 }
        )
      end
    end

    context 'with stale zendesk queue items' do
      let(:zq_created_at) { 11.minutes.ago }
      let(:zendesk_queue) {
        [double(Sidekiq::Job, created_at: zq_created_at)]
      }

      it { is_expected.not_to be_ok }

      it 'reports the zendesk check as false' do
        expect(subject.checks).to include(zendesk: false)
      end

      it 'reports the zendesk queue status' do
        expect(subject.queues).to include(
          zendesk: { oldest: zq_created_at, count: 1 }
        )
      end
    end

    context 'with an inactive database' do
      before do
        allow(ActiveRecord::Base.connection).
          to receive(:active?).
          and_return(false)
      end

      it { is_expected.not_to be_ok }

      it 'reports the database check as false' do
        expect(subject.checks).to include(database: false)
      end
    end

    context 'with an unreachable database' do
      before do
        allow(ActiveRecord::Base.connection).
          to receive(:active?).
          and_raise(PG::ConnectionBad)
      end

      it { is_expected.not_to be_ok }

      it 'reports the database check as false' do
        expect(subject.checks).to include(database: false)
      end
    end

    context 'with another database exception' do
      before do
        allow(ActiveRecord::Base.connection).
          to receive(:active?).
          and_raise(Exception)
      end

      it { is_expected.not_to be_ok }

      it 'reports the database check as false' do
        expect(subject.checks).to include(database: false)
      end
    end

    context 'with the Sidekiq API' do
      before do
        allow(Sidekiq::Queue).to receive(:new).and_raise('queue problem')
      end

      it 'reports the queue checks as false' do
        expect(subject.checks).to include(
          mailers: false,
          zendesk: false
        )
      end

      it 'reports the queue status' do
        expect(subject.queues).to eq(
          mailers: { oldest: nil, count: 0 },
          zendesk: { oldest: nil, count: 0 }
        )
      end
    end
  end
end
