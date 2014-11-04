require 'spec_helper'

describe Deferred::SlotsController do
  render_views

  before :each do
    Timecop.freeze(Time.local(2013, 12, 1, 12, 0))
    session[:visit] = Visit.new(visit_id: SecureRandom.hex, prisoner: Prisoner.new, visitors: [Visitor.new], slots: [])
  end
  
  context "correct slot information" do
    let(:slots_hash) do
      {
        visit: {
          slots: [
                  {
                    slot: '2013-01-01-1345-2000'
                  }
                 ]
        },
      }
    end

    it "permits us to select a time slot" do
      post :update, slots_hash
      response.should redirect_to(edit_deferred_visit_path)
    end
  end

  context "no slots" do
    let(:slots_hash) do
      {
        visit: { slots: [{slot: ''}] }
      }
    end

    it "prompts us to retry" do
      post :update, slots_hash
      response.should redirect_to(edit_deferred_slots_path)
    end
  end

  context "exactly three slots" do
    let(:slots_hash) do
      {
        visit: { slots: [{slot: '2013-01-01-1200-1300'}] * 3 }
      }
    end

    it "accepts the submission" do
      post :update, slots_hash
      response.should redirect_to(edit_deferred_visit_path)
    end
  end

  context "exactly two slots" do
    let(:slots_hash) do
      {
        visit: { slots: [{slot: '2013-01-01-1200-1300'}] * 2 }
      }
    end

    it "accepts the submission" do
      post :update, slots_hash
      response.should redirect_to(edit_deferred_visit_path)
    end
  end

  context "too many slots" do
    let(:slots_hash) do
      {
        visit: { slots: [{ slot: '2013-01-01-1200-1300' }] * 4 }
      }
    end

    it "prompts us to retry" do
      post :update, slots_hash
      response.should redirect_to(edit_deferred_slots_path)
      session[:visit].errors[:slots].should_not be_nil
    end
  end
end
