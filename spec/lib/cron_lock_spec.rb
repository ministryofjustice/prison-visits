require 'spec_helper'

describe CronLock do
  let :redis_client do
    double('redis_client')
  end

  subject do
    CronLock.new(redis_client)
  end

  context "lock was acquired" do
    before :each do
      redis_client.should_receive(:set).and_return(true)
      redis_client.should_receive(:del)
    end

    context "no error ocurred" do
      it "runs the underlying task" do
        ran = false
        subject.run do
          ran = true
        end
        ran.should be_true
      end
    end

    context "an error occurs" do
      it "aborts the task and removes the lock" do
        ran = false
        expect { 
          subject.run do
            raise
            ran = true
          end
        }.to raise_error(RuntimeError)
        ran.should be_false
      end
    end
  end

  context "lock was not acquired" do
    before :each do
      redis_client.should_receive(:set).and_return(false)
      redis_client.should_receive(:run_internal).never
      redis_client.should_receive(:del).never
    end

    it "doesn't run anything" do
      subject.run do
        fail
      end
    end
  end
end
