require 'rails_helper'

RSpec.describe Instant::SlotsController, type: :controller do
  render_views

  before :each do
    Timecop.freeze(Time.local(2013, 12, 1, 12, 0))
    session[:visit] = Visit.new(
      visit_id: SecureRandom.hex,
      prisoner: Prisoner.new(prison_name: 'Durham'),
      visitors: [Visitor.new],
      slots: []
    )
    cookies['cookies-enabled'] = 1
  end

  after :each do
    Timecop.return
  end

  it_behaves_like "a browser without a session present"
  it_behaves_like "a session timed out"
  it_behaves_like "a killswitch-enabled controller"

  it "sets up the flow" do
    expect(controller.this_path).to eq(instant_edit_slots_path)
    expect(controller.next_path).to eq(instant_edit_visit_path)
  end

  it "permits up to one slot to be selected" do
    expect(controller.max_slots).to eq(1)
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
      expect(response).to redirect_to(controller.next_path)
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
      expect(response).to redirect_to(controller.this_path)
    end
  end

  context "too many slots" do
    let(:slots_hash) do
      {
        visit: { slots: [{ slot: '2013-01-01-1200-1300' }] * 2 }
      }
    end

    it "prompts us to retry" do
      post :update, slots_hash
      expect(response).to redirect_to(controller.this_path)
      expect(session[:visit].errors[:slots]).not_to be_nil
    end
  end
end
